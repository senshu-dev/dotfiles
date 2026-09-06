package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

type mode int

const (
	modeCommit mode = iota
	modePreview
	modeToggleVariant
)

func main() {
	if err := run(os.Args[1:]); err != nil {
		fmt.Fprintln(os.Stderr, "themegen:", err)
		os.Exit(1)
	}
}

func run(args []string) error {
	m, variant, imagePath, err := parseArgs(args)
	if err != nil {
		return err
	}

	dir, err := quickshellDir()
	if err != nil {
		return err
	}
	host := hostnameOrEmpty()

	switch m {
	case modeToggleVariant:
		return runToggleVariant(dir, host)
	case modePreview:
		return runGenerate(dir, host, imagePath, variant, true)
	default:
		return runGenerate(dir, host, imagePath, variant, false)
	}
}

func parseArgs(args []string) (m mode, variant string, imagePath string, err error) {
	variant = "auto"
	m = modeCommit
	var positional []string

	for i := 0; i < len(args); i++ {
		switch args[i] {
		case "--toggle-variant":
			m = modeToggleVariant
		case "--preview":
			m = modePreview
			i++
			if i >= len(args) {
				return 0, "", "", fmt.Errorf("--preview requires an image path")
			}
			imagePath = args[i]
		case "--variant":
			i++
			if i >= len(args) {
				return 0, "", "", fmt.Errorf("--variant requires a value")
			}
			variant = args[i]
		default:
			positional = append(positional, args[i])
		}
	}

	if m == modePreview {
		if variant != "dark" && variant != "light" {
			return 0, "", "", fmt.Errorf("--preview requires an explicit --variant dark|light, got %q", variant)
		}
		return m, variant, imagePath, nil
	}

	if variant != "auto" && variant != "dark" && variant != "light" {
		return 0, "", "", fmt.Errorf("--variant must be auto, dark, or light, got %q", variant)
	}

	if len(positional) > 0 {
		imagePath = positional[0]
	}
	return m, variant, imagePath, nil
}

func runToggleVariant(dir, host string) error {
	current, err := resolveActiveThemeName(dir, host)
	if err != nil {
		return err
	}
	next := "Dynamic"
	if current == "Dynamic" {
		next = "Dynamic Light"
	}
	if _, err := os.Stat(filepath.Join(dir, "themes", next+".json")); os.IsNotExist(err) {
		return fmt.Errorf("themes/%s.json doesn't exist yet — run themegen against a wallpaper first", next)
	}
	return commitThemeName(dir, host, next)
}

func runGenerate(dir, host, imagePath, variant string, preview bool) error {
	if imagePath == "" {
		path, err := activeWallpaperPath()
		if err != nil {
			return fmt.Errorf("no image path given and couldn't query the active wallpaper: %w", err)
		}
		imagePath = path
	}

	if variant == "auto" {
		current, err := resolveActiveThemeName(dir, host)
		if err != nil {
			return err
		}
		variant = "dark"
		if current == "Dynamic Light" {
			variant = "light"
		}
	}

	out, err := runMatugen(imagePath)
	if err != nil {
		return err
	}

	if preview {
		theme, err := BuildTheme(out, variant)
		if err != nil {
			return err
		}
		return writeThemeFile(filepath.Join(dir, "themes", ".preview.json"), theme)
	}

	darkTheme, err := BuildTheme(out, "dark")
	if err != nil {
		return err
	}
	lightTheme, err := BuildTheme(out, "light")
	if err != nil {
		return err
	}
	if err := writeThemeFile(filepath.Join(dir, "themes", "Dynamic.json"), darkTheme); err != nil {
		return err
	}
	if err := writeThemeFile(filepath.Join(dir, "themes", "Dynamic Light.json"), lightTheme); err != nil {
		return err
	}

	name := "Dynamic"
	if variant == "light" {
		name = "Dynamic Light"
	}
	return commitThemeName(dir, host, name)
}

func writeThemeFile(path string, theme Theme) error {
	out, err := json.MarshalIndent(theme, "", "  ")
	if err != nil {
		return err
	}
	tmp := path + ".tmp"
	if err := os.WriteFile(tmp, append(out, '\n'), 0o644); err != nil {
		return err
	}
	return os.Rename(tmp, path)
}

func runMatugen(imagePath string) (MatugenOutput, error) {
	cmd := exec.Command("matugen", "image", imagePath, "--json", "hex", "--source-color-index", "0")
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	if err := cmd.Run(); err != nil {
		return MatugenOutput{}, fmt.Errorf("matugen failed: %w (stderr: %s)", err, stderr.String())
	}
	var out MatugenOutput
	if err := json.Unmarshal(stdout.Bytes(), &out); err != nil {
		return MatugenOutput{}, fmt.Errorf("parsing matugen output: %w", err)
	}
	return out, nil
}

// activeWallpaperPath queries hyprpaper directly rather than depending on
// whatever launched themegen to pass a path — see design spec's "Wiring"
// section. Output looks like:
//   DP-1: /home/user/walls/foo.jpg
//   HDMI-A-1: /home/user/walls/foo.jpg
// First monitor line wins (see design spec's Non-goals: per-monitor
// themes are out of scope, matches wallpaper.sh's one-image-both-monitors
// convention).
func activeWallpaperPath() (string, error) {
	cmd := exec.Command("hyprctl", "hyprpaper", "listactive")
	var stdout bytes.Buffer
	cmd.Stdout = &stdout
	if err := cmd.Run(); err != nil {
		return "", fmt.Errorf("hyprctl hyprpaper listactive failed: %w", err)
	}
	lines := strings.Split(strings.TrimSpace(stdout.String()), "\n")
	if len(lines) == 0 || lines[0] == "" {
		return "", fmt.Errorf("hyprctl hyprpaper listactive returned no active wallpaper")
	}
	parts := strings.SplitN(lines[0], ":", 2)
	if len(parts) != 2 {
		return "", fmt.Errorf("unexpected hyprctl hyprpaper listactive output: %q", lines[0])
	}
	return strings.TrimSpace(parts[1]), nil
}

func quickshellDir() (string, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(home, ".config", "quickshell"), nil
}

func hostnameOrEmpty() string {
	b, err := os.ReadFile("/etc/hostname")
	if err != nil {
		return ""
	}
	return strings.TrimSpace(string(b))
}
