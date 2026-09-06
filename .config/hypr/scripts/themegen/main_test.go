package main

import "testing"

func TestParseArgs_Default(t *testing.T) {
	m, variant, path, err := parseArgs(nil)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if m != modeCommit || variant != "auto" || path != "" {
		t.Errorf("got mode=%v variant=%q path=%q, want commit/auto/\"\"", m, variant, path)
	}
}

func TestParseArgs_ExplicitVariantAndPath(t *testing.T) {
	m, variant, path, err := parseArgs([]string{"--variant", "dark", "/tmp/wall.jpg"})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if m != modeCommit || variant != "dark" || path != "/tmp/wall.jpg" {
		t.Errorf("got mode=%v variant=%q path=%q", m, variant, path)
	}
}

func TestParseArgs_Preview(t *testing.T) {
	m, variant, path, err := parseArgs([]string{"--preview", "/tmp/wall.jpg", "--variant", "light"})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if m != modePreview || variant != "light" || path != "/tmp/wall.jpg" {
		t.Errorf("got mode=%v variant=%q path=%q", m, variant, path)
	}
}

func TestParseArgs_PreviewRequiresExplicitVariant(t *testing.T) {
	if _, _, _, err := parseArgs([]string{"--preview", "/tmp/wall.jpg"}); err == nil {
		t.Error("expected an error when --preview is given without --variant, got nil")
	}
}

func TestParseArgs_ToggleVariant(t *testing.T) {
	m, _, _, err := parseArgs([]string{"--toggle-variant"})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if m != modeToggleVariant {
		t.Errorf("got mode=%v, want modeToggleVariant", m)
	}
}

func TestParseArgs_InvalidVariant(t *testing.T) {
	if _, _, _, err := parseArgs([]string{"--variant", "sepia"}); err == nil {
		t.Error("expected an error for an invalid --variant value, got nil")
	}
}
