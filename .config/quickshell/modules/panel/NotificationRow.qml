import QtQuick
import QtQuick.Layouts

import qs.services
import qs.components

// Compact `.notif` row from design/Panels.dc.html -- icon-in-square,
// title/body, trailing relative time. Distinct from the bigger
// widgets/NotificationCard.qml (a toast-style card with optional image,
// backing design/Toast.dc.html's transient popups -- a separate,
// untouched concern this component does not replace).
RowLayout {
    id: root

    property string iconName: ""
    property string title: ""
    property string body: ""
    property string time: ""

    spacing: 10

    Rectangle {
        Layout.preferredWidth: 32
        Layout.preferredHeight: 32
        radius: 9
        color: Theme.accentMuted
        Icon { anchors.centerIn: parent; name: root.iconName; size: 15; color: Theme.textDim }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2
        Text {
            Layout.fillWidth: true
            text: root.title
            color: Theme.text
            font.family: Config.font.family
            font.bold: true
            font.pixelSize: 13
            elide: Text.ElideRight
        }
        Text {
            Layout.fillWidth: true
            text: root.body
            color: Theme.textFaint
            font.family: Config.font.family
            font.pixelSize: 12
            elide: Text.ElideRight
        }
    }

    Text {
        Layout.alignment: Qt.AlignTop
        text: root.time
        color: Theme.textFaint
        font.family: Config.font.family
        font.pixelSize: 10
    }
}
