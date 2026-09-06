import QtQuick
import QtQuick.Layouts

import qs.services
import qs.components

// `.slider-row` from design/Panels.dc.html: icon + draggable track + value
// label. `value` is the only source of truth -- the DragHandler below uses
// `target: null` and derives `value` from the gesture's own position
// instead of letting Qt drag the thumb directly, so it never fights the
// declarative x binding on the thumb/fill. Content wires `moved` to
// Audio.setVolume/Brightness.set (same calls old Sidebar.qml's
// RailButtonTile already makes today).
RowLayout {
    id: root

    property string iconName: ""
    property real value: 0.5 // 0..1

    signal moved(real value)

    spacing: 10

    Icon { name: root.iconName; size: 15; color: Theme.textDim }

    Item {
        id: track
        Layout.fillWidth: true
        implicitHeight: 14 // hit-target taller than the 6px visual groove

        Rectangle { // groove
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width; height: 6; radius: 999
            color: Theme.accentMuted
        }
        Rectangle { // fill
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width * root.value; height: 6; radius: 999
            color: Theme.accent
        }
        Rectangle { // thumb
            x: parent.width * root.value - width / 2
            anchors.verticalCenter: parent.verticalCenter
            width: 14; height: 14; radius: 7
            color: "#ffffff"
        }

        HoverHandler { cursorShape: Qt.PointingHandCursor }
        DragHandler {
            target: null
            onCentroidChanged: {
                root.value = Math.max(0, Math.min(1, centroid.position.x / track.width))
                root.moved(root.value)
            }
        }
        TapHandler {
            onTapped: point => {
                root.value = Math.max(0, Math.min(1, point.position.x / track.width))
                root.moved(root.value)
            }
        }
    }

    Text {
        Layout.preferredWidth: 32
        horizontalAlignment: Text.AlignRight
        text: Math.round(root.value * 100) + "%"
        color: Theme.textFaint
        font.family: Config.font.family
        font.pixelSize: 12
    }
}
