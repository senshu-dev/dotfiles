import QtQuick
import Quickshell
import Quickshell.Io
import "sshconfig.js" as SshConfig

Item {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property int maxIncludeDepth: 16

    property var pluginService: null
    property var hosts: []

    property var pendingHosts: []
    property var seenFiles: ({})
    property int depth: 0
    property var queued: null
    property bool busy: false

    signal itemsChanged()

    // Globs are expanded by sh (no eval), so config contents never execute.
    Process {
        id: reader
        onRunningChanged: {
            if (running || !root.queued)
                return;
            const next = root.queued;
            root.queued = null;
            root.readRound(next);
        }
        stdout: StdioCollector {
            onStreamFinished: root.consumeRound(text)
        }
    }

    function refresh() {
        if (busy)
            return;
        busy = true;
        pendingHosts = [];
        seenFiles = {};
        depth = 0;
        readRound([home + "/.ssh/config"]);
    }

    function readRound(patterns) {
        reader.command = ["sh", "-c", "IFS='\n'; for p in \"$@\"; do for f in $p; do [ -f \"$f\" ] && printf '\\036%s\\n' \"$f\" && cat \"$f\"; done; done", "sh"].concat(patterns);
        reader.running = true;
    }

    function consumeRound(out) {
        const next = [];
        for (const record of out.split("\x1e").slice(1)) {
            const nl = record.indexOf("\n");
            const file = record.slice(0, nl);
            if (seenFiles[file])
                continue;
            seenFiles[file] = true;
            const res = SshConfig.parse(record.slice(nl + 1), home);
            pendingHosts = pendingHosts.concat(res.hosts);
            next.push(...res.includes);
        }
        depth++;
        if (next.length && depth < maxIncludeDepth) {
            if (reader.running)
                queued = next;
            else
                readRound(next);
            return;
        }
        hosts = pendingHosts;
        busy = false;
        itemsChanged();
    }

    function getItems(query) {
        const q = (query || "").toLowerCase();
        if (!q)
            refresh();
        return hosts.filter(h => !q || h.alias.toLowerCase().includes(q) || h.hostname.toLowerCase().includes(q)).map(h => ({
                    name: h.alias,
                    icon: "material:terminal",
                    comment: (h.user ? h.user + "@" : "") + h.hostname,
                    host: h.alias,
                    categories: ["SSH"]
                }));
    }

    function executeItem(item) {
        if (!item || !item.host)
            return;
        Quickshell.execDetached(["kitty", "ssh", item.host]);
    }

    Component.onCompleted: refresh()
}
