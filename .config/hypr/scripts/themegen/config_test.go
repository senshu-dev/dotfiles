package main

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func writeFile(t *testing.T, path, content string) {
	t.Helper()
	if err := os.WriteFile(path, []byte(content), 0o644); err != nil {
		t.Fatalf("writing %s: %v", path, err)
	}
}

func TestResolveActiveThemeName_BaseOnly(t *testing.T) {
	dir := t.TempDir()
	writeFile(t, filepath.Join(dir, "config.json"), `{"theme":{"name":"Rose Pine Moon"}}`)

	got, err := resolveActiveThemeName(dir, "")
	if err != nil {
		t.Fatalf("resolveActiveThemeName returned error: %v", err)
	}
	if got != "Rose Pine Moon" {
		t.Errorf("got %q, want %q", got, "Rose Pine Moon")
	}
}

func TestResolveActiveThemeName_HostOverrides(t *testing.T) {
	dir := t.TempDir()
	writeFile(t, filepath.Join(dir, "config.json"), `{"theme":{"name":"Rose Pine Moon"}}`)
	writeFile(t, filepath.Join(dir, "config.desktop.json"), `{"theme":{"name":"Nord"}}`)

	got, err := resolveActiveThemeName(dir, "desktop")
	if err != nil {
		t.Fatalf("resolveActiveThemeName returned error: %v", err)
	}
	if got != "Nord" {
		t.Errorf("got %q, want %q — host config should win", got, "Nord")
	}
}

func TestResolveActiveThemeName_HostWithoutThemeKeyDoesNotOverride(t *testing.T) {
	dir := t.TempDir()
	writeFile(t, filepath.Join(dir, "config.json"), `{"theme":{"name":"Rose Pine Moon"}}`)
	writeFile(t, filepath.Join(dir, "config.laptop.json"), `{"layout":{"radius":12}}`)

	got, err := resolveActiveThemeName(dir, "laptop")
	if err != nil {
		t.Fatalf("resolveActiveThemeName returned error: %v", err)
	}
	if got != "Rose Pine Moon" {
		t.Errorf("got %q, want %q — host file doesn't define theme.name, base should win", got, "Rose Pine Moon")
	}
}

func TestCommitThemeName_WritesBaseAndHostWhenHostDefinesTheme(t *testing.T) {
	dir := t.TempDir()
	writeFile(t, filepath.Join(dir, "config.json"), `{"theme":{"name":"Rose Pine Moon"},"font":{"family":"Annotation Mono"}}`)
	writeFile(t, filepath.Join(dir, "config.desktop.json"), `{"theme":{"name":"Nord"},"sidebar":{"width":210}}`)

	if err := commitThemeName(dir, "desktop", "Dynamic"); err != nil {
		t.Fatalf("commitThemeName returned error: %v", err)
	}

	base, _, err := readThemeName(filepath.Join(dir, "config.json"))
	if err != nil || base != "Dynamic" {
		t.Errorf("base config.json theme.name = %q, err=%v, want %q", base, err, "Dynamic")
	}
	host, _, err := readThemeName(filepath.Join(dir, "config.desktop.json"))
	if err != nil || host != "Dynamic" {
		t.Errorf("host config.desktop.json theme.name = %q, err=%v, want %q", host, err, "Dynamic")
	}

	b, _ := os.ReadFile(filepath.Join(dir, "config.json"))
	if !strings.Contains(string(b), "Annotation Mono") {
		t.Errorf("config.json lost unrelated keys: %s", b)
	}
	b2, _ := os.ReadFile(filepath.Join(dir, "config.desktop.json"))
	if !strings.Contains(string(b2), "210") {
		t.Errorf("config.desktop.json lost unrelated keys: %s", b2)
	}
}

func TestCommitThemeName_DoesNotAddThemeKeyToHostThatLacksOne(t *testing.T) {
	dir := t.TempDir()
	writeFile(t, filepath.Join(dir, "config.json"), `{"theme":{"name":"Rose Pine Moon"}}`)
	writeFile(t, filepath.Join(dir, "config.laptop.json"), `{"layout":{"radius":12}}`)

	if err := commitThemeName(dir, "laptop", "Dynamic"); err != nil {
		t.Fatalf("commitThemeName returned error: %v", err)
	}

	_, ok, err := readThemeName(filepath.Join(dir, "config.laptop.json"))
	if err != nil {
		t.Fatalf("readThemeName returned error: %v", err)
	}
	if ok {
		t.Error("host config.laptop.json should stay untouched (no theme key defined), but now has one")
	}
}
