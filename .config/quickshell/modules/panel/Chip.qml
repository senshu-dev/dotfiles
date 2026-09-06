import QtQuick
import QtQuick.Layouts

import qs.services
import qs.components

// Shared by Overview's performance-mode chips and Settings' toggle-grid --
// design/Panels.dc.html's `.chip` and `.toggle` are the same shape (icon
// above label, 12px radius, accent fill when active). Tap flips `active`
// locally for visual QA only -- no service call yet (Content wires each
// consumer's real toggle).
Rectangle {
    id: root

    property string iconName: ""
    property string label: ""
    property bool active: false
    property bool showRecDot: false

    signal tapped()

    implicitHeight: col.implicitHeight + 20
    radius: 12
    color: root.active ? Theme.accent : Theme.surface
    border.width: root.active ? 0 : 1
    border.color: Theme.borderSoft
    Behavior on color { ColorAnimation { duration: 120 } }

    ColumnLayout {
        id: col
        anchors.centerIn: parent
        spacing: 5

        Icon {
            Layout.alignment: Qt.AlignHCenter
            name: root.iconName
            size: 16
            color: root.active ? Theme.accentInk : Theme.textDim
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.label
            color: root.active ? Theme.accentInk : Theme.textDim
            font.family: Config.font.family
            font.pixelSize: 11
        }
    }

    Rectangle {
        visible: root.showRecDot
        anchors { top: parent.top; right: parent.right; topMargin: 6; rightMargin: 8 }
        width: 6; height: 6; radius: 3
        color: Theme.danger
    }

    HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
    TapHandler { onTapped: { root.active = !root.active; root.tapped() } }
}
