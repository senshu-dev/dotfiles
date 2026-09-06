import QtQuick

// Bespoke US-flag glyph for the Settings keyboard-layout row -- a real
// flag's colors are drawn as-is, not theme-derived, matching
// design/Panels.dc.html's own hardcoded .flag/.canton/.stripe divs.
// Static/decorative this phase; Content swaps the flag per the real
// detected layout.
Item {
    implicitWidth: 22
    implicitHeight: 16

    Rectangle {
        anchors.fill: parent
        radius: 3
        color: "#b22234"
        clip: true

        Repeater {
            model: 6
            delegate: Rectangle {
                required property int index
                y: index * (parent.height / 6.5)
                width: parent.width
                height: parent.height / 13
                color: "#ffffff"
            }
        }

        Rectangle {
            anchors { left: parent.left; top: parent.top }
            width: parent.width * 0.44
            height: parent.height * 0.54
            color: "#3c3b6e"
        }
    }
}
