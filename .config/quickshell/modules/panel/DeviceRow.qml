import QtQuick
import QtQuick.Layouts

import qs.services
import qs.components

// `.device-row` from design/Panels.dc.html: icon-in-square, name/sub,
// chevron. Tap/hover feedback wired (matches every other row in this
// shell); the handler body is empty this phase -- Content wires each
// row's real drill-down (DeviceMenu.qml) or layout-query action.
// `leading` lets a consumer (the Keyboard row) swap the default
// icon-square for something else (a Flag) without a special-case prop.
RowLayout {
    id: root

    property string iconName: ""
    property string name: ""
    property string sub: ""
    default property alias leading: leadingSlot.data

    signal tapped()

    spacing: 12

    Item {
        id: leadingSlot
        Layout.preferredWidth: 34
        Layout.preferredHeight: 34

        Rectangle {
            visible: leadingSlot.children.length === 0
            anchors.fill: parent
            radius: 10
            color: Theme.accentMuted
            Icon { anchors.centerIn: parent; name: root.iconName; size: 16; color: Theme.textDim }
        }
    }

    ColumnLayout {
        spacing: 2
        Text { text: root.name; color: Theme.text; font.family: Config.font.family; font.bold: true; font.pixelSize: 13 }
        Text { text: root.sub; color: Theme.textFaint; font.family: Config.font.family; font.pixelSize: 12 }
    }

    Item { Layout.fillWidth: true }

    Icon { name: "chevron-up"; rotation: 90; size: 14; color: Theme.textFaint }

    HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
    TapHandler { onTapped: root.tapped() }
}
