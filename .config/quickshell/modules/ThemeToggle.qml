import Quickshell
import Quickshell.Io
import QtQuick

// SUPER+T: instant light/dark flip, no window. Both Dynamic.json/Dynamic
// Light.json always already exist (written together by every themegen
// run) so this never needs matugen -- just flips which name config.json
// points at, via themegen's own commit logic (not reimplemented here).
Item {
    id: root

    function toggle(): void {
        Quickshell.execDetached(["sh", "-c", "~/.local/bin/themegen --toggle-variant"])
    }

    IpcHandler {
        target: "thememenu"
        function toggle(): void { root.toggle() }
    }
}
