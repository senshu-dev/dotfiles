package main

import (
	"encoding/json"
	"testing"
)

// Fixture: real matugen output (trimmed to the roles this package reads),
// captured 2026-09-05 via:
//   matugen image ~/walls/unsorted/a_cup_of_coffee_with_a_heart_shaped_foam_in_it.jpg \
//     --json hex --source-color-index 0 --dry-run
const fixtureJSON = `{
  "colors": {
    "background":                { "dark": {"color": "#0f1512"}, "light": {"color": "#f5fbf6"} },
    "surface_container_high":    { "dark": {"color": "#252b29"}, "light": {"color": "#e4eae5"} },
    "surface_container_highest": { "dark": {"color": "#303633"}, "light": {"color": "#dee4df"} },
    "outline_variant":           { "dark": {"color": "#3f4945"}, "light": {"color": "#bfc9c3"} },
    "outline":                   { "dark": {"color": "#89938e"}, "light": {"color": "#707974"} },
    "on_background":             { "dark": {"color": "#dee4df"}, "light": {"color": "#171d1a"} },
    "on_surface_variant":        { "dark": {"color": "#bfc9c3"}, "light": {"color": "#3f4945"} },
    "primary":                   { "dark": {"color": "#88d6bb"}, "light": {"color": "#146b55"} },
    "tertiary":                  { "dark": {"color": "#a8cbe2"}, "light": {"color": "#406376"} }
  }
}`

func fixture(t *testing.T) MatugenOutput {
	t.Helper()
	var out MatugenOutput
	if err := json.Unmarshal([]byte(fixtureJSON), &out); err != nil {
		t.Fatalf("failed to parse fixture JSON: %v", err)
	}
	return out
}

func TestBuildTheme_Dark(t *testing.T) {
	got, err := BuildTheme(fixture(t), "dark")
	if err != nil {
		t.Fatalf("BuildTheme returned error: %v", err)
	}
	want := Theme{
		Variant:     "dark",
		Background:  "#0f1512",
		Surface:     "#252b29",
		Primary:     "#303633",
		Secondary:   "#89938e",
		Accent:      "#88d6bb",
		AccentHover: "#a8cbe2",
		AccentMuted: "#3f4945",
		Text:        "#dee4df",
		TextDim:     "#bfc9c3",
	}
	if got != want {
		t.Errorf("BuildTheme(dark) = %+v, want %+v", got, want)
	}
}

func TestBuildTheme_Light(t *testing.T) {
	got, err := BuildTheme(fixture(t), "light")
	if err != nil {
		t.Fatalf("BuildTheme returned error: %v", err)
	}
	want := Theme{
		Variant:     "light",
		Background:  "#f5fbf6",
		Surface:     "#e4eae5",
		Primary:     "#dee4df",
		Secondary:   "#707974",
		Accent:      "#146b55",
		AccentHover: "#406376",
		AccentMuted: "#bfc9c3",
		Text:        "#171d1a",
		TextDim:     "#3f4945",
	}
	if got != want {
		t.Errorf("BuildTheme(light) = %+v, want %+v", got, want)
	}
}

func TestBuildTheme_MissingRole(t *testing.T) {
	out := MatugenOutput{Colors: map[string]MatugenColorRole{}}
	if _, err := BuildTheme(out, "dark"); err == nil {
		t.Error("expected an error for missing color roles, got nil")
	}
}
