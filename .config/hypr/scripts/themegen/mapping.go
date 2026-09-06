package main

import "fmt"

// MatugenColorRole is one entry of matugen's `--json hex` output under
// "colors" — one Material You role, both variants always populated
// regardless of which --mode was requested (verified live, see design
// spec's "matugen invocation" section).
type MatugenColorRole struct {
	Dark struct {
		Color string `json:"color"`
	} `json:"dark"`
	Light struct {
		Color string `json:"color"`
	} `json:"light"`
}

// MatugenOutput is the subset of `matugen ... --json hex`'s output this
// package reads.
type MatugenOutput struct {
	Colors map[string]MatugenColorRole `json:"colors"`
}

// Theme mirrors themes/*.json's shape exactly — field order matches the
// design spec's "Token mapping" table.
type Theme struct {
	Variant     string `json:"variant"`
	Background  string `json:"background"`
	Surface     string `json:"surface"`
	Primary     string `json:"primary"`
	Secondary   string `json:"secondary"`
	Accent      string `json:"accent"`
	AccentHover string `json:"accentHover"`
	AccentMuted string `json:"accentMuted"`
	Text        string `json:"text"`
	TextDim     string `json:"textDim"`
}

func colorFor(out MatugenOutput, role, variant string) (string, error) {
	c, ok := out.Colors[role]
	if !ok {
		return "", fmt.Errorf("matugen output missing color role %q", role)
	}
	if variant == "light" {
		return c.Light.Color, nil
	}
	return c.Dark.Color, nil
}

// BuildTheme maps matugen's Material You roles onto this repo's nine
// theme tokens for one variant ("dark" or "light"). See the design spec's
// "Token mapping" table for why each pairing was chosen — derived from
// real luminance ordering against the 16 static themes being replaced,
// not guessed.
func BuildTheme(out MatugenOutput, variant string) (Theme, error) {
	var t Theme
	t.Variant = variant

	fields := []struct {
		role string
		dst  *string
	}{
		{"background", &t.Background},
		{"surface_container_high", &t.Surface},
		{"surface_container_highest", &t.Primary},
		{"outline", &t.Secondary},
		{"primary", &t.Accent},
		{"tertiary", &t.AccentHover},
		{"outline_variant", &t.AccentMuted},
		{"on_background", &t.Text},
		{"on_surface_variant", &t.TextDim},
	}
	for _, f := range fields {
		v, err := colorFor(out, f.role, variant)
		if err != nil {
			return Theme{}, err
		}
		*f.dst = v
	}
	return t, nil
}
