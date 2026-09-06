import QtQuick
import QtQuick.Layouts

import qs.services
import qs.components

// `.stat` from design/Panels.dc.html: icon+label row, big value text, thin
// bar-meter beneath. Track/fill colors match components/Progress.qml's
// ring gauge (accentMuted track, accent fill) -- same pair, linear instead
// of circular. `showBar: false` for uptime, which has no natural 0-100
// range (mirrors old Sidebar.qml's gaugeC/textC split for this exact stat).
ColumnLayout {
    id: root

    property string iconName: ""
    property string label: ""
    property string value: ""
    property real fraction: 0
    property bool showBar: true

    spacing: 6

    RowLayout {
        spacing: 6
        Icon { name: root.iconName; size: 13; color: Theme.textFaint }
        Text {
            text: root.label
            color: Theme.textFaint
            font.family: Config.font.family
            font.pixelSize: 11
        }
    }

    Text {
        text: root.value
        color: Theme.text
        font.family: Config.font.family
        font.bold: true
        font.pixelSize: 15
    }

    Rectangle {
        visible: root.showBar
        Layout.fillWidth: true
        height: 5
        radius: 999
        color: Theme.accentMuted

        Rectangle {
            width: parent.width * root.fraction
            height: parent.height
            radius: 999
            color: Theme.accent
        }
    }
}
