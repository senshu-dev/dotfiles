import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "xrayVpn"

    readonly property string scriptCmd: "$HOME/.config/hypr/scripts/xray-instance.sh"

    PluginGlobalVar {
        id: tunActive
        varName: "tunActive"
        defaultValue: false
    }

    function toggleTun() {
        const cmd = tunActive.value ? "stop tun" : "start tun";
        Proc.runCommand("xrayVpn.settingsToggle", ["sh", "-c", scriptCmd + " " + cmd], () => {});
    }

    Row {
        width: parent.width
        spacing: Theme.spacingM

        Column {
            width: parent.width - toggle.width - Theme.spacingM
            spacing: Theme.spacingXS
            anchors.verticalCenter: parent.verticalCenter

            StyledText {
                text: I18n.tr("Tunnel Active")
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Font.Medium
                color: Theme.surfaceText
            }

            StyledText {
                text: I18n.tr("Full system-wide capture via xray-instance.sh (tun mode)")
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        DankToggle {
            id: toggle
            anchors.verticalCenter: parent.verticalCenter
            checked: tunActive.value
            onToggled: isChecked => root.toggleTun()
        }
    }
}
