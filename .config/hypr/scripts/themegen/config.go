package main

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
)

// readThemeName reads path's top-level theme.name key, if present. ok is
// false (not an error) when the file doesn't exist, or exists but doesn't
// define theme.name — both are normal for a per-host config file, which
// is optional and may only set unrelated keys.
func readThemeName(path string) (name string, ok bool, err error) {
	b, err := os.ReadFile(path)
	if os.IsNotExist(err) {
		return "", false, nil
	}
	if err != nil {
		return "", false, err
	}
	var doc map[string]json.RawMessage
	if err := json.Unmarshal(b, &doc); err != nil {
		return "", false, fmt.Errorf("parsing %s: %w", path, err)
	}
	rawTheme, present := doc["theme"]
	if !present {
		return "", false, nil
	}
	var theme struct {
		Name string `json:"name"`
	}
	if err := json.Unmarshal(rawTheme, &theme); err != nil {
		return "", false, fmt.Errorf("parsing %s theme key: %w", path, err)
	}
	if theme.Name == "" {
		return "", false, nil
	}
	return theme.Name, true, nil
}

// writeThemeName atomically sets path's top-level theme.name key,
// preserving every other key exactly (temp-file-then-rename — a plain
// truncating write isn't picked up reliably by Config.qml's
// FileView.watchChanges, matching ThemeMenu.qml's existing commit()).
func writeThemeName(path, name string) error {
	b, err := os.ReadFile(path)
	if err != nil {
		return fmt.Errorf("reading %s: %w", path, err)
	}
	var doc map[string]json.RawMessage
	if err := json.Unmarshal(b, &doc); err != nil {
		return fmt.Errorf("parsing %s: %w", path, err)
	}
	theme := map[string]json.RawMessage{}
	if raw, ok := doc["theme"]; ok {
		if err := json.Unmarshal(raw, &theme); err != nil {
			return fmt.Errorf("parsing %s theme key: %w", path, err)
		}
	}
	nameJSON, err := json.Marshal(name)
	if err != nil {
		return err
	}
	theme["name"] = nameJSON
	themeJSON, err := json.Marshal(theme)
	if err != nil {
		return err
	}
	doc["theme"] = themeJSON

	out, err := json.MarshalIndent(doc, "", "  ")
	if err != nil {
		return err
	}
	tmp := path + ".tmp"
	if err := os.WriteFile(tmp, append(out, '\n'), 0o644); err != nil {
		return err
	}
	return os.Rename(tmp, path)
}

// resolveActiveThemeName resolves the currently active theme.name inside
// dir (a quickshell config directory) the same way every existing
// propagation script (theme-variant.sh, gtk-palette.py,
// sync-hyprlock-theme.py, kitty/sync-theme.py) already does: base
// config.json, overridden by config.<host>.json if that file defines
// theme.name too. host == "" means treat as base-only (no host file).
func resolveActiveThemeName(dir, host string) (string, error) {
	name, ok, err := readThemeName(filepath.Join(dir, "config.json"))
	if err != nil {
		return "", err
	}
	if !ok {
		name = "Nord" // matches Config.qml's own default
	}
	if host == "" {
		return name, nil
	}
	hostPath := filepath.Join(dir, fmt.Sprintf("config.%s.json", host))
	hostName, hostOk, err := readThemeName(hostPath)
	if err != nil {
		return "", err
	}
	if hostOk {
		return hostName, nil
	}
	return name, nil
}

// commitThemeName sets theme.name to name in dir's base config.json, and
// also in config.<host>.json if — and only if — that file already
// defines theme.name itself. See the design spec's "Config commit"
// section: on this host config.desktop.json pins theme.name
// independently and wins the merge, so writing only base would silently
// do nothing visible.
func commitThemeName(dir, host, name string) error {
	if err := writeThemeName(filepath.Join(dir, "config.json"), name); err != nil {
		return err
	}
	if host == "" {
		return nil
	}
	hostPath := filepath.Join(dir, fmt.Sprintf("config.%s.json", host))
	_, hostDefinesTheme, err := readThemeName(hostPath)
	if err != nil {
		return err
	}
	if hostDefinesTheme {
		return writeThemeName(hostPath, name)
	}
	return nil
}
