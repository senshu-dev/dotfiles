import QtQuick
import QtQuick.Layouts

import qs.services
import qs.components

// `.empty` from design/EmptyStates.dc.html: circular icon badge + title +
// wrapped subtitle, centered in whatever space contains it.
ColumnLayout {
    id: root

    property string iconName: ""
    property string title: ""
    property string subtitle: ""

    spacing: 12

    Rectangle {
        Layout.alignment: Qt.AlignHCenter
        width: 56; height: 56; radius: 28
        color: Theme.surface
        border.width: 1
        border.color: Theme.borderSoft
        Icon { anchors.centerIn: parent; name: root.iconName; size: 24; color: Theme.textFaint }
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: root.title
        color: Theme.textDim
        font.family: Config.font.family
        font.bold: true
        font.pixelSize: 14
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 200
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        text: root.subtitle
        color: Theme.textFaint
        font.family: Config.font.family
        font.pixelSize: 12
    }
}
