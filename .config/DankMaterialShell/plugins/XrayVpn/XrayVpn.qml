import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root
    property var popoutService: null

    readonly property string scriptCmd: "$HOME/.config/hypr/scripts/xray-instance.sh"

    PluginGlobalVar {
        id: tunActive
        varName: "tunActive"
        defaultValue: false
    }

    function refreshStatus() {
        Proc.runCommand("xrayVpn.status", ["sh", "-c", scriptCmd + " status tun"], (stdout, exitCode) => {
            tunActive.set(stdout.trim() === "active");
        });
    }

    function toggleTun() {
        const cmd = tunActive.value ? "stop tun" : "start tun";
        Proc.runCommand("xrayVpn.toggle", ["sh", "-c", scriptCmd + " " + cmd], (stdout, exitCode) => {
            refreshStatus();
        });
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshStatus()
    }

    ccWidgetIcon: "vpn_lock"
    ccWidgetPrimaryText: I18n.tr("Xray VPN")
    ccWidgetSecondaryText: tunActive.value ? I18n.tr("Connected") : I18n.tr("Disconnected")
    ccWidgetIsActive: tunActive.value

    onCcWidgetToggled: root.toggleTun()
}
