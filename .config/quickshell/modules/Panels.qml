import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import qs.services
import qs.components
import qs.widgets
import "panel"

// Overview (left) + Settings (right), opened/closed together from one
// trigger -- TopBar's pill tap (wired in shell.qml) or SUPER+N (`qs ipc
// call panel toggle`). Foundation phase (sub-project 4a): every value
// below is a hardcoded sample -- see
// docs/superpowers/specs/2026-09-05-linux-rising-panels-foundation-design.md.
// Content (4b) swaps each one for a live service binding and deletes
// Sidebar.qml. The three `visible:` bindings on host-conditional stats
// (Battery/GPU) and the Brightness slider are the only real service reads
// in this file -- everything else is static until then.
Item {
    id: root

    property bool open: false
    function toggle(): void { root.open = !root.open }
    function close(): void { root.open = false }

    IpcHandler {
        target: "panel"
        function toggle(): void { root.toggle() }
    }

    component PanelWindowShell: PanelWindow {
        id: shellWin
        default property alias content: body.data
        property alias headerTitle: headerLabel.text

        screen: Quickshell.screens[1] // primary
        color: "transparent"
        // -1 (wlr-layer-shell's "ignore other surfaces' exclusive zones")
        // so this window starts at true absolute y=0, level with
        // TopBar.qml's own bar-pill, instead of being auto-stacked below
        // TopBar's reserved 54px zone (12+40+2) the way a plain
        // exclusiveZone:0 top-anchored surface would be.
        exclusiveZone: -1
        visible: root.open
        implicitWidth: 412

        mask: Region { item: card }

        Rectangle {
            id: card
            anchors.fill: parent
            anchors.margins: 14
            radius: 26
            color: Theme.panelBg
            border.width: 1
            border.color: Theme.border

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#8c000000"
                // card's own margin (14px) is the hard clip boundary for
                // this shadow's bleed -- blurMax:40 (the design's original
                // value) overshot that badly once these windows switched
                // to exclusiveZone:-1 sizing, visibly clipping the shadow
                // against the window edge. Sized to fit inside 14px.
                blurMax: 10
                shadowBlur: 1.0
                shadowVerticalOffset: 3
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                Text {
                    id: headerLabel
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    color: Theme.textFaint
                    font.family: Config.font.family
                    font.pixelSize: 11
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: 2
                }

                ColumnLayout {
                    id: body
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 14
                }
            }
        }
    }

    // Shared shell for the top-strip dropdowns (calendar, workspace
    // clusters) added in the panels-refinement follow-up -- mirrors
    // TopBar.qml's own bar-pill centering technique (a transparent
    // full-width strip, `mask` restricted to the one visible card) since
    // these live in a separate window from the bar-pill but need to look
    // like they drop down from directly beneath it. `xOffset` shifts the
    // visible card left/right of screen-center for the two workspace
    // clusters; 0 (default) centers it, used by the calendar.
    component DropdownShell: PanelWindow {
        id: dropWin
        default property alias content: dropBody.data
        property real xOffset: 0
        property bool bare: false
        // `level: true` (workspace clusters) keeps this window at true
        // absolute y=0 via exclusiveZone:-1, level with TopBar.qml's own
        // bar-pill. `level: false` (calendar, default) stays a plain
        // exclusiveZone:0 top-anchored surface, auto-stacked below
        // TopBar's reserved 54px zone (12+40+2) -- dropped beneath the
        // pill, which is the calendar's intended look.
        property bool level: false

        screen: Quickshell.screens[1] // primary
        color: "transparent"
        exclusiveZone: dropWin.level ? -1 : 0
        visible: root.open
        anchors { top: true; left: true; right: true }
        implicitHeight: dropCard.y + dropCard.implicitHeight + 20

        mask: Region { item: dropCard }

        Rectangle {
            id: dropCard
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: dropWin.xOffset
            // level:false (calendar): window origin auto-stacks to
            // absolute y=54 below TopBar's own reserved zone -- y:10 here
            // lands the card at absolute 64, a 12px gap below the pill's
            // own absolute bottom edge (y=52).
            // level:true (workspace clusters): exclusiveZone:-1 keeps the
            // window's origin at true absolute y=0 -- y:12 here lands the
            // card at the pill's own absolute y, level with it.
            y: dropWin.level ? 12 : 10
            implicitWidth: dropBody.implicitWidth + (dropWin.bare ? 0 : 32)
            implicitHeight: dropBody.implicitHeight + (dropWin.bare ? 0 : 32)
            radius: dropWin.bare ? 0 : 20
            color: dropWin.bare ? "transparent" : Theme.panelBg
            border.width: dropWin.bare ? 0 : 1
            border.color: Theme.border

            layer.enabled: !dropWin.bare
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#8c000000"
                // dropCard's own y (10px, level:false) is the tightest
                // clip boundary this shadow bleeds against -- sized to
                // fit inside it (same clipping problem and fix as
                // PanelWindowShell's card shadow above).
                blurMax: 6
                shadowBlur: 1.0
                shadowVerticalOffset: 2
            }

            ColumnLayout {
                id: dropBody
                x: dropWin.bare ? 0 : 16
                y: dropWin.bare ? 0 : 16
                width: dropCard.width - (dropWin.bare ? 0 : 32)
            }
        }
    }

    PanelWindowShell {
        id: overviewWin
        anchors { left: true; top: true; bottom: true }
        headerTitle: "Overview"

        // 1. Profile row + tray (CLAUDE.md: "tray -> next to the profile row")
        PanelCard {
            Layout.fillWidth: true
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                Rectangle {
                    Layout.preferredWidth: 46; Layout.preferredHeight: 46; radius: 23
                    color: Theme.surface
                    border.width: 1; border.color: Theme.borderSoft
                    Text { anchors.centerIn: parent; text: "A"; color: Theme.textDim; font.family: Config.font.family; font.bold: true; font.pixelSize: 16 }
                }
                ColumnLayout {
                    spacing: 2
                    Text { text: "Alex Rivera"; color: Theme.text; font.family: Config.font.family; font.bold: true; font.pixelSize: 14 }
                    Text { text: "@arivera"; color: Theme.textFaint; font.family: Config.font.family; font.pixelSize: 12 }
                }
                Item { Layout.fillWidth: true }
                RowLayout {
                    spacing: 5
                    Icon { name: "github"; size: 14; color: Theme.accent }
                    Text { text: "GitHub"; color: Theme.accent; font.family: Config.font.family; font.pixelSize: 12 }
                }
            }
            Text {
                Layout.fillWidth: true
                text: "42 repositories · 128 followers · building in the open"
                color: Theme.textDim
                font.family: Config.font.family
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 6
                visible: SystemTray.items.length > 0

                Repeater {
                    model: SystemTray.items
                    delegate: Item {
                        required property var modelData
                        width: 22; height: 22
                        Image {
                            anchors.centerIn: parent
                            // modelData.icon is already a Quickshell image-provider
                            // URL for SNI items -- use it as-is, same as
                            // modules/sidebar/RailTrayTile.qml.
                            source: modelData.icon
                            sourceSize: Qt.size(18, 18)
                        }
                        TapHandler {
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onTapped: (point, button) => {
                                if (button === Qt.RightButton || modelData.hasMenu)
                                    modelData.display(overviewWin, point.position.x, point.position.y)
                                else
                                    modelData.activate()
                            }
                        }
                    }
                }
            }
        }

        // 2. Power menu button
        Rectangle {
            Layout.fillWidth: true
            height: 42
            radius: 12
            color: powerHover.hovered ? Theme.accentHover : Theme.accent
            Behavior on color { ColorAnimation { duration: 120 } }
            RowLayout {
                anchors.centerIn: parent
                spacing: 8
                Icon { name: "power"; size: 16; color: Theme.accentInk }
                Text { text: "Power menu"; color: Theme.accentInk; font.family: Config.font.family; font.bold: true; font.pixelSize: 13 }
            }
            HoverHandler { id: powerHover; cursorShape: Qt.PointingHandCursor }
            TapHandler { onTapped: {} } // Content: same ipcCall("powermenu") old RailButtonTile already makes
        }

        // 3. Performance-mode chips
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Chip { Layout.fillWidth: true; iconName: "leaf"; label: "Saver" }
            Chip { Layout.fillWidth: true; iconName: "scale"; label: "Balanced"; active: true }
            Chip { Layout.fillWidth: true; iconName: "rocket"; label: "Boost" }
        }

        // 4. Expanded stat grid -- cpu/mem/battery (mockup's original 3) plus
        // gpu/disk/download/upload/temp (CLAUDE.md's additions) plus uptime
        // (no bar, mirrors old Sidebar.qml's gaugeC/textC split). Battery and
        // GPU are the two real, live, host-conditional bindings in this
        // section -- everything else here is a hardcoded sample.
        GridLayout {
            Layout.fillWidth: true
            columns: 3
            rowSpacing: 14
            columnSpacing: 14
            StatTile { Layout.fillWidth: true; iconName: "cpu"; label: "CPU"; value: "34%"; fraction: 0.34 }
            StatTile { Layout.fillWidth: true; iconName: "ram"; label: "RAM"; value: "61%"; fraction: 0.61 }
            StatTile { Layout.fillWidth: true; visible: Battery.available; iconName: "battery"; label: "BAT"; value: "78%"; fraction: 0.78 }
            StatTile { Layout.fillWidth: true; visible: SystemUsage.hasGpu; iconName: "gpu"; label: "GPU"; value: "22%"; fraction: 0.22 }
            StatTile { Layout.fillWidth: true; iconName: "disk"; label: "SSD"; value: "48%"; fraction: 0.48 }
            StatTile { Layout.fillWidth: true; iconName: "download"; label: "DOWN"; value: "4.2 MB/s"; fraction: 0.35 }
            StatTile { Layout.fillWidth: true; iconName: "upload"; label: "UP"; value: "0.8 MB/s"; fraction: 0.1 }
            StatTile { Layout.fillWidth: true; iconName: "temperature"; label: "TEMP"; value: "56°C"; fraction: 0.56 }
            StatTile { Layout.fillWidth: true; iconName: "cpu"; label: "UPTIME"; value: "3h 12m"; showBar: false }
        }

        // 5. Media player
        PanelCard {
            Layout.fillWidth: true
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                Rectangle {
                    Layout.preferredWidth: 46; Layout.preferredHeight: 46; radius: 12
                    color: Theme.accentMuted
                    Icon { anchors.centerIn: parent; name: "music"; size: 20; color: Theme.textDim }
                }
                ColumnLayout {
                    spacing: 2
                    Text { text: "Nightcall"; color: Theme.text; font.family: Config.font.family; font.bold: true; font.pixelSize: 13 }
                    Text { text: "Kavinsky"; color: Theme.textFaint; font.family: Config.font.family; font.pixelSize: 12 }
                }
            }
            Rectangle {
                Layout.fillWidth: true
                height: 4
                radius: 999
                color: Theme.accentMuted
                Rectangle { width: parent.width * 0.42; height: parent.height; radius: 999; color: Theme.accent }
            }
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10
                Rectangle {
                    width: 30; height: 30; radius: 15
                    color: Theme.surface
                    Icon { anchors.centerIn: parent; name: "shuffle"; size: 13; color: Theme.textDim }
                }
                Rectangle {
                    width: 30; height: 30; radius: 15
                    color: Theme.surface
                    Icon { anchors.centerIn: parent; name: "prev"; size: 14; color: Theme.textDim }
                }
                Rectangle {
                    width: 34; height: 34; radius: 17
                    color: Theme.accent
                    Icon { anchors.centerIn: parent; name: "play"; size: 15; color: Theme.accentInk }
                }
                Rectangle {
                    width: 30; height: 30; radius: 15
                    color: Theme.surface
                    Icon { anchors.centerIn: parent; name: "next"; size: 14; color: Theme.textDim }
                }
                Rectangle {
                    width: 30; height: 30; radius: 15
                    color: Theme.surface
                    Icon { anchors.centerIn: parent; name: "repeat"; size: 13; color: Theme.textDim }
                }
            }
        }

        // 6. Notifications -- capped preview + real "Clear all" + stub
        // "View all". No .card wrapper: design/Panels.dc.html's .notif
        // rows sit directly in the panel background, each with its own
        // top border (the mockup's .notif CSS applies border-top
        // unconditionally, no :first-child exception -- verified
        // directly in the file). See CLAUDE.md's Parked tasks: "View
        // all" is wired together with a future launcher/command/
        // notifications menu-window pass, not standalone here.
        ColumnLayout {
            id: notifSection
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            property var sample: [
                { icon: "updates", title: "System update ready", body: "Restart to finish installing", time: "2m" },
                { icon: "message", title: "Message from Jordan", body: "\"Ready when you are\"", time: "18m" },
                { icon: "message", title: "Message from Sam", body: "\"Lunch at noon?\"", time: "41m" },
                { icon: "updates", title: "Backup complete", body: "42 files archived", time: "1h" }
            ]
            readonly property int shownCap: 3

            RowLayout {
                Layout.fillWidth: true
                Text { text: "NOTIFICATIONS"; color: Theme.textFaint; font.family: Config.font.family; font.pixelSize: 11; font.letterSpacing: 2 }
                Item { Layout.fillWidth: true }
                Text {
                    text: "Clear all"
                    color: Theme.textFaint
                    font.family: Config.font.family
                    font.pixelSize: 11
                    visible: notifSection.sample.length > 0
                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                    // Content: NotificationService.clearAll() -- dismiss() looped
                    // over the full tracked list, not just what's shown here.
                    TapHandler { onTapped: {} }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: notifSection.sample.length === 0
                EmptyState {
                    anchors.centerIn: parent
                    iconName: "bell"
                    title: "All caught up"
                    subtitle: "No new notifications right now"
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: notifSection.sample.length > 0
                clip: true
                spacing: 8

                Repeater {
                    model: notifSection.sample.slice(0, notifSection.shownCap)
                    delegate: ColumnLayout {
                        required property var modelData
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.borderSoft }
                        NotificationRow {
                            Layout.fillWidth: true
                            iconName: modelData.icon
                            title: modelData.title
                            body: modelData.body
                            time: modelData.time
                        }
                    }
                }

                Text {
                    visible: notifSection.sample.length > notifSection.shownCap
                    text: "View all"
                    color: Theme.accent
                    font.family: Config.font.family
                    font.pixelSize: 12
                    // Stub only -- CLAUDE.md Parked tasks: wired to a future
                    // NotificationsMenu.qml together with the launcher/command
                    // menu-window set, not part of this sub-project.
                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: {} }
                }

                Item { Layout.fillHeight: true }
            }
        }
    }

    PanelWindowShell {
        anchors { right: true; top: true; bottom: true }
        headerTitle: "Settings"

        // 1. Quick-toggle grid -- mockup's 6 plus VPN (CLAUDE.md), 3
        // columns, last row partial (GridLayout handles that with no
        // special case).
        GridLayout {
            Layout.fillWidth: true
            columns: 3
            rowSpacing: 10
            columnSpacing: 10
            Chip { Layout.fillWidth: true; iconName: "wifi"; label: "Wi-Fi"; active: true }
            Chip { Layout.fillWidth: true; iconName: "bluetooth"; label: "Bluetooth"; active: true }
            Chip { Layout.fillWidth: true; iconName: "plane"; label: "Airplane" }
            Chip { Layout.fillWidth: true; iconName: "bell"; label: "DND" }
            Chip { Layout.fillWidth: true; iconName: "nightlight"; label: "Night Light" }
            Chip { Layout.fillWidth: true; iconName: "record"; label: "Screen Rec."; active: true; showRecDot: true }
            Chip { Layout.fillWidth: true; iconName: "vpn"; label: "VPN" }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.borderSoft }

        // 2. Keyboard layout -- flag glyph, not text (CLAUDE.md explicit
        // call; this is *input* layout, unrelated to old Sidebar.qml's
        // dropped tiling-layout "hyprlayout" text tile). No existing
        // service covers a real layout query yet -- Content's job.
        PanelCard {
            Layout.fillWidth: true
            DeviceRow {
                Layout.fillWidth: true
                name: "Keyboard"
                sub: "English (US)"
                Flag {}
            }
        }

        // 3-6. Wi-Fi / Bluetooth / Output / Input device rows -- each its
        // own card (design/Panels.dc.html wraps every device-row in a
        // .card; Output's card holds its device row AND its volume
        // slider together, matching the mockup's own grouping exactly).
        PanelCard {
            Layout.fillWidth: true
            DeviceRow { Layout.fillWidth: true; iconName: "wifi"; name: "Wi-Fi"; sub: "Home-5G" }
        }
        PanelCard {
            Layout.fillWidth: true
            DeviceRow { Layout.fillWidth: true; iconName: "bluetooth"; name: "Bluetooth"; sub: "Rising Buds" }
        }
        PanelCard {
            Layout.fillWidth: true
            DeviceRow { Layout.fillWidth: true; iconName: "volume"; name: "Output"; sub: "Studio Speakers" }
            SliderRow { Layout.fillWidth: true; iconName: "volume"; value: 0.69 }
        }
        PanelCard {
            Layout.fillWidth: true
            DeviceRow { Layout.fillWidth: true; iconName: "mic"; name: "Input"; sub: "Built-in Microphone" }
            // Mute button removed per explicit user request -- the mute
            // interaction will be redesigned later, not just re-added here.
            SliderRow { Layout.fillWidth: true; iconName: "mic"; value: 0.55 }
        }

        Item { Layout.fillHeight: true }

        // 7. Brightness -- bottom, host-conditional (live), own card per
        // explicit user request (deviates from design/Panels.dc.html,
        // which leaves this one bare -- the user's call over the mockup).
        PanelCard {
            Layout.fillWidth: true
            visible: Brightness.available
            SliderRow {
                Layout.fillWidth: true
                iconName: "brightness"
                value: 0.82
            }
        }
    }

    DropdownShell {
        CalendarWidget {}
    }

    // Two per-monitor workspace-indicator dropdowns, flanking the
    // bar-pill's own horizontal position rather than the screen edges.
    // The +-200 offset is a static, tuned-by-eye measurement (screenshot-
    // cropped and pixel-measured directly against a live bar-pill
    // instance -- see the panels-refinement SDD ledger) giving a clean
    // gap against the pill's own ~180px measured width, which
    // `WorkspaceCluster.implicitWidth` now matches -- these are
    // independent windows with no reference to TopBar.qml's internal
    // geometry, so this is not bound to the pill's real runtime width
    // (which does vary with live weather/date text length).
    DropdownShell {
        xOffset: -200
        bare: true
        level: true
        WorkspaceCluster { activeIndex: 1 }
    }
    DropdownShell {
        xOffset: 200
        bare: true
        level: true
        visible: root.open && Quickshell.screens.length > 1
        WorkspaceCluster { activeIndex: 1 }
    }
}
