import QtQuick
import QtQuick.Layouts

import qs.services

// `.card` from design/Panels.dc.html: Theme.surface fill, soft 1px
// border, 16px radius, 14px padding, 10px internal spacing -- restored
// to these original values by panels-refinement now that the calendar
// and workspace row moved out of Overview into top-strip dropdowns,
// freeing the budget that forced a tighter 6/8 scale during the
// panels-foundation spacing-polish round. Same padded-card shell as
// components/NotificationPanel.qml, minus its built-in title -- every
// Overview/Settings section composes its own heading text where one is
// needed.
Rectangle {
    id: root

    default property alias content: col.data
    property int padding: 14

    implicitHeight: col.implicitHeight + 2 * root.padding

    color: Theme.surface
    radius: 16
    border.width: 1
    border.color: Theme.borderSoft

    ColumnLayout {
        id: col
        x: root.padding
        y: root.padding
        width: root.width - 2 * root.padding
        spacing: 10
    }
}
