import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import qs.services

// Top-center pill: clock, date, weather — nothing else. Fixed size, no
// hover-expand, no in-place content morph. Tapping it toggles the Panels
// window pair (wired in shell.qml); SUPER+` (see keybindings.lua) toggles
// this bar's own autohide, unrelated and unchanged from before.
PanelWindow {
    id: win

    screen: Quickshell.screens[1] // primary

    // Set from shell.qml (panels.open) — drives the active-ring visual
    // only. TopBar does not own the panels' open/close state.
    property bool panelsOpen: false
    signal panelsToggleRequested()

    color: "transparent"
    anchors { top: true; left: true; right: true }
    implicitHeight: 70

    property bool autohidden: false
    visible: !autohidden
    // Top gap is just the pill's own y (12px, screen edge to pill — layer
    // shells aren't subject to Hyprland's tiling gaps). Bottom gap is our
    // reserved padding (2px) PLUS Hyprland's general:gaps_out (10px on
    // this host, applied to the first tiled window below), so 2+10=12
    // matches the top's 12 exactly. If gaps_out changes, this 2 needs to
    // change with it to stay symmetric.
    exclusiveZone: autohidden ? 0 : (12 + 40 + 2)

    function toggleAutohide(): void { win.autohidden = !win.autohidden }

    IpcHandler {
        target: "topbar"
        function toggle(): void { win.toggleAutohide() }
    }

    // Only the pill itself takes clicks; the rest of the transparent strip
    // passes clicks through to whatever's tiled underneath.
    mask: Region { item: pill }

    readonly property string tempText: Weather.now ? (Weather.now.temp + "°") : "--°"
    readonly property string weatherIconSource: Weather.now
        ? Quickshell.shellPath("assets/weather/" + Weather.iconFor(Weather.now.code) + ".svg")
        : ""

    Rectangle {
        id: pill
        anchors.horizontalCenter: parent.horizontalCenter
        y: 12
        width: pillRow.implicitWidth + 32
        height: 40
        radius: 12
        color: Theme.panelBg
        border.width: win.panelsOpen ? 2 : 1
        border.color: win.panelsOpen ? Theme.accentRing : Theme.borderSoft

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#8c000000" // black @ 0.55
            blurMax: 24
            shadowBlur: 1.0
            shadowVerticalOffset: 4
        }

        TapHandler {
            onTapped: win.panelsToggleRequested()
        }

        RowLayout {
            id: pillRow
            anchors.centerIn: parent
            spacing: 10

            ColumnLayout {
                spacing: 0
                Text {
                    text: Time.clockTime
                    color: Theme.text
                    font.family: Config.font.family
                    font.bold: true
                    font.pixelSize: 13
                }
                Text {
                    text: Time.longDate
                    color: Theme.textFaint
                    font.family: Config.font.family
                    font.pixelSize: 10
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                Layout.topMargin: 4
                Layout.bottomMargin: 4
                color: Theme.borderSoft
            }

            RowLayout {
                spacing: 6
                Image {
                    Layout.preferredWidth: 15
                    Layout.preferredHeight: 15
                    sourceSize: Qt.size(15, 15)
                    fillMode: Image.PreserveAspectFit
                    source: win.weatherIconSource
                }
                Text {
                    text: win.tempText
                    color: Theme.accent
                    font.family: Config.font.family
                    font.bold: true
                    font.pixelSize: 13
                }
            }
        }
    }
}
