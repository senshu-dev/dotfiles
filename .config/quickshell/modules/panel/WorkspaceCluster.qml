import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import qs.services

// Pill-styled cluster of 4 workspace dots, one per monitor, consumed by
// the two top-strip workspace dropdowns in Panels.qml (see
// docs/superpowers/specs/2026-09-06-linux-rising-panels-refinement-design.md,
// part B2). Static sample only -- no live Hyprland data, no
// click-to-switch (services/Hyprland.qml wiring is a deliberate later
// step). Same glass-pill visual language as TopBar.qml's own bar-pill:
// Theme.panelBg fill, Theme.borderSoft border, radius 12, height 40 --
// reads as a matching "second row" beside it. Width matches the
// bar-pill's own approximate width (TopBar.qml's pill is ~220-260px
// depending on live weather/date text) so the two read as a matched
// set, not a narrow afterthought -- dots spread out to fill that width
// evenly (each in its own equal-width flex slot) rather than clustering
// together with large empty margins on either side.
Rectangle {
    id: root

    property int activeIndex: 1 // which of the 4 dots is "active" (sample)

    implicitWidth: 180
    implicitHeight: 40
    radius: 12
    color: Theme.panelBg
    border.width: 1
    border.color: Theme.borderSoft

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: "#8c000000"
        // This pill sits close to its own DropdownShell window's edge
        // (level:true -- only 12px of clearance above it) -- sized to
        // fit inside that, same clipping problem/fix as Panels.qml's
        // card shadows.
        blurMax: 6
        shadowBlur: 1.0
        shadowVerticalOffset: 2
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        Repeater {
            model: 4
            delegate: Item {
                required property int index
                readonly property bool active: index === root.activeIndex
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Rounded square, not a circle -- radius is well under
                // half the side length, unlike a pill/dot shape.
                Rectangle {
                    anchors.centerIn: parent
                    width: 18; height: 18
                    radius: 5
                    color: active ? Theme.accent : "transparent"
                    border.width: active ? 0 : 1
                    border.color: Theme.borderSoft
                }
            }
        }
    }
}
