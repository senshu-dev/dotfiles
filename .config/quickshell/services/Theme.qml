pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "scripts/color.js" as ColorUtils

Singleton {
    id: root

    // previewName wins when set (live preview from the theme switcher); empty
    // falls back to the committed Config.theme.name.
    property string previewName: ""
    property string currentTheme: root.previewName !== "" ? root.previewName : Config.theme.name

    property color background
    property color surface
    property color primary
    property color secondary
    property color accent
    property color accentHover
    property color accentMuted
    property color text
    property color textDim

    // Linux Rising tokens — additive. Each is a *binding* computed from the
    // properties above, so every existing themes/*.json palette works with
    // no JSON edits. A palette file CAN still override one of these by name
    // (loadColors() below copies any matching key generically) — but doing
    // so replaces the binding with a fixed value permanently for that
    // property until the file that set it is reloaded with the key present
    // again. None of the 16 current theme files define any of these keys,
    // so this caveat doesn't apply yet; it matters once sub-project 2's
    // generated theme file might.
    property color textFaint: Qt.rgba(textDim.r, textDim.g, textDim.b, textDim.a * 0.58)
    property color border: Qt.rgba(text.r, text.g, text.b, 0.10)
    property color borderSoft: Qt.rgba(text.r, text.g, text.b, 0.06)
    property color panelBg: Qt.rgba(background.r, background.g, background.b, 0.90)
    property color accentSoft: Qt.rgba(accent.r, accent.g, accent.b, 0.16)
    property color accentRing: Qt.rgba(accent.r, accent.g, accent.b, 0.45)
    property color accentInk: ColorUtils.isDark(accent.r, accent.g, accent.b) ? "#f5f2ec" : "#1a1208"
    property color danger: "#e8735f"
    property color dangerSoft: Qt.rgba(danger.r, danger.g, danger.b, 0.16)
    property color success: "#7dd0a0"

    // Call after every preview regeneration. previewName's VALUE stays
    // ".preview" across repeated preview runs (only the file it points at
    // changes), so a plain `previewName = ".preview"` re-assignment is a
    // QML no-op after the first call -- no change signal fires, so
    // themeFile's `path` binding never re-evaluates. themegen (main.go's
    // writeThemeFile) writes via write-tmp-then-rename, which replaces the
    // file's inode on every run; themeFile's `watchChanges` inotify watch
    // is bound to the inode it first loaded and goes stale after that
    // first replacement, silently missing every later preview write.
    // reload() re-reads unconditionally, sidestepping the stale watch.
    function reloadPreview(): void { themeFile.reload() }

    function loadColors(text: string): void {
        try {
            const data = JSON.parse(text)
            for (const key of Object.keys(data)) {
                if (root[key] !== undefined) {
                    root[key] = data[key]
                }
            }
        } catch (e) {
            console.warn(`Theme: failed to parse ${root.currentTheme}.json: ${e?.message ?? e}`)
        }
    }

    FileView {
        id: themeFile
        path: Quickshell.shellPath(`themes/${root.currentTheme}.json`)
        watchChanges: true
        onLoaded: root.loadColors(text())
        onFileChanged: root.loadColors(text())
        onLoadFailed: err => console.warn(`Theme: ${root.currentTheme}.json not loaded: ${FileViewError.toString(err)}`)
    }
}
