import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Qt.labs.folderlistmodel

import qs.services
import qs.components

// SUPER+W: browse ~/walls by folder, live-preview the resulting theme on
// the whole desktop as you browse (reuses Theme.previewName exactly the
// way ThemeMenu used to for its own hover-preview -- see ThemeToggle.qml
// for what ThemeMenu was reduced to), Apply commits both the real
// wallpaper and the theme together. Matches design canvas
// design/WallpaperTheme.dc.html. ~/walls is 1,637 images across 51 flat
// folders (confirmed directly -- no folder nests further except
// .github/{templates,workflows}, repo metadata from the dharmx/walls
// mirror, excluded here since it holds no images) so folder-chip
// navigation is load-bearing, not polish.
PanelWindow {
    id: win

    screen: Quickshell.screens[1] // primary
    visible: false
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    focusable: true
    exclusiveZone: 0

    // No "All" option: Qt.labs.folderlistmodel.FolderListModel has no
    // recursive-scan property (confirmed against the installed plugin's
    // plugins.qmltypes -- its property list is folder/rootFolder/
    // parentFolder/nameFilters/sortField/sortReversed/showFiles/showDirs/
    // showDirsFirst/showDotAndDotDot/showHidden/showOnlyReadable/
    // caseSensitive/count/status/sortCaseSensitive, nothing recursive), so
    // a flat view of ~/walls's root would show nothing (no loose image
    // files sit there, only the 51 category subfolders). Defaults to the
    // first folder alphabetically instead -- set once, the first time
    // `folders` finishes loading (see the Connections block below).
    property string selectedFolder: ""
    property string selectedPath: ""
    property string appearance: Theme.currentTheme === "Dynamic Light" ? "light" : "dark"
    // Which output(s) Apply sets the wallpaper on -- "both" (default, all
    // of monitorNames) or one specific hyprctl output name to leave the
    // others' wallpaper alone. monitorNames is queried fresh from
    // `hyprctl monitors -j` on every open() rather than hardcoded --
    // this host has "DP-1"/"HDMI-A-1", but a laptop's internal panel is
    // typically named "eDP-1", and any hardcoded pair would silently
    // break theme generation entirely on a host where the first name
    // doesn't exist (hyprctl errors, the `&&`-chained themegen call after
    // it never runs).
    property string targetMonitor: "both"
    property var monitorNames: []

    Process {
        id: monitorsProc
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    win.monitorNames = JSON.parse(text).map(m => m.name)
                } catch (e) {
                    console.warn(`WallpaperTheme: failed to parse hyprctl monitors output: ${e?.message ?? e}`)
                }
                if (!win.monitorNames.includes(win.targetMonitor)) win.targetMonitor = "both"
            }
        }
    }

    function open(): void {
        win.selectedPath = ""
        win.appearance = Theme.currentTheme === "Dynamic Light" ? "light" : "dark"
        monitorsProc.exec(["hyprctl", "monitors", "-j"])
        win.visible = true
    }
    function close(): void {
        Theme.previewName = ""
        win.visible = false
    }
    function toggle(): void { win.visible ? win.close() : win.open() }
    function cancel(): void { win.close() }

    // Runs the wallpaper+theme commit and only clears the preview override
    // (see close()) once it has actually finished -- execDetached has no
    // completion signal, so flipping previewName right after firing it (the
    // old code) raced the real commit: the shell would fall back to
    // Config.theme.name before commitThemeName had rewritten it. Same
    // Process-then-onExited idiom as shell.qml's kittyTheme/variantProc.
    Process {
        id: applyProc
        onExited: {
            Theme.previewName = ""
            win.visible = false
        }
    }

    function apply(): void {
        if (win.selectedPath === "") {
            // No new wallpaper picked -- theme-only change. themegen falls
            // back to the currently active wallpaper (activeWallpaperPath())
            // when given no path, so this still regenerates the palette
            // against it under the newly picked variant.
            applyProc.command = ["sh", "-c", '~/.local/bin/themegen --variant "$1"', "sh", win.appearance]
        } else {
            const monitors = win.targetMonitor === "both" ? win.monitorNames : [win.targetMonitor]
            // Real, currently-connected output names (see monitorNames'
            // own comment) -- never a hardcoded pair. Each is a closed-set
            // value from hyprctl's own JSON, not user-typed text, so
            // embedding it directly in the script is safe; $1 (the image
            // path) still goes through as its own argv entry.
            const wallpaperCmds = monitors.map(m => `hyprctl hyprpaper wallpaper "${m},$1"`).join(" && ")
            applyProc.command = ["sh", "-c",
                (wallpaperCmds.length > 0 ? wallpaperCmds + " && " : "") + '~/.local/bin/themegen "$1" --variant "$2"',
                "sh", win.selectedPath, win.appearance]
        }
        applyProc.running = false
        applyProc.running = true
    }

    IpcHandler {
        target: "wallpapertheme"
        function toggle(): void { win.toggle() }
        function open(): void { win.open() }
        function close(): void { win.close() }
    }

    // Debounced preview: fast browsing across several tiles doesn't fire
    // a matugen run per tile, same pattern as shell.qml's own
    // previewDebounce Timer for kitty.
    Timer {
        id: previewDebounce
        interval: 150
        onTriggered: win.runPreview()
    }

    function requestPreview(path: string): void {
        win.selectedPath = path
        previewDebounce.restart()
    }

    // Same reasoning as applyProc above: only flip previewName once matugen
    // has actually finished writing themes/.preview.json. Setting it eagerly
    // (the old code) could show whatever variant a *previous* preview run
    // had left in that file -- sometimes the opposite light/dark variant --
    // for as long as this run took to catch up.
    Process {
        id: previewProc
        onExited: {
            Theme.previewName = ".preview"
            Theme.reloadPreview()
        }
    }

    function runPreview(): void {
        if (win.selectedPath === "") return
        previewProc.command = ["sh", "-c",
            '~/.local/bin/themegen --preview "$1" --variant "$2"', "sh",
            win.selectedPath, win.appearance]
        previewProc.running = false
        previewProc.running = true
    }

    onAppearanceChanged: if (win.selectedPath !== "") previewDebounce.restart()

    // Global search across all of ~/walls's 51 folders by filename.
    // FolderListModel (used by `images` below) has no recursive-scan
    // property (see the file-header comment), so a query can't just widen
    // `images.folder` to the root -- shells out to `find` instead, same
    // Process-plus-debounce idiom as the preview above. Empty query falls
    // back to normal per-folder browsing (`images`); a non-empty one drives
    // the grid from `searchResults` across every folder instead.
    property string searchQuery: ""
    property var searchResults: []

    Timer {
        id: searchDebounce
        interval: 150
        onTriggered: win.runSearch()
    }

    function requestSearch(query: string): void {
        win.searchQuery = query
        searchDebounce.restart()
    }

    Process {
        id: searchProc
        stdout: StdioCollector {
            onStreamFinished: {
                win.searchResults = text.split("\n")
                    .filter(p => p.length > 0)
                    .map(p => ({ fileName: p.slice(p.lastIndexOf("/") + 1), filePath: p }))
            }
        }
    }

    function runSearch(): void {
        if (win.searchQuery === "") { win.searchResults = []; return }
        // $1 is the query, passed as its own argv entry (never
        // string-interpolated into the -c script) so quotes/spaces/shell
        // metacharacters the user types can't break out of the -iname
        // argument.
        searchProc.exec(["sh", "-c",
            'find "$HOME/walls" -type f \\( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \\) -iname "*$1*" | sort',
            "sh", win.searchQuery])
    }

    // Folder chips: ~/walls's own subfolders that contain images.
    FolderListModel {
        id: folders
        folder: Qt.resolvedUrl(Quickshell.env("HOME") + "/walls")
        showDirs: true
        showFiles: false
        showDotAndDotDot: false
        sortField: FolderListModel.Name
    }

    // Pick the first folder once the scan finishes -- guarded on
    // selectedFolder still being "" so this only ever fires once, not on
    // every reload while the window stays open.
    Connections {
        target: folders
        function onStatusChanged(): void {
            if (folders.status === FolderListModel.Ready && win.selectedFolder === "" && folders.count > 0) {
                win.selectedFolder = folders.get(0, "fileName")
            }
        }
    }

    // Images in the selected folder -- one level only, no recursion
    // needed, every category folder is flat (confirmed directly). Falls
    // back to ~/walls's root (empty -- no loose files there) for the
    // brief window before the Connections block above picks a folder.
    FolderListModel {
        id: images
        folder: win.selectedFolder !== ""
            ? Qt.resolvedUrl(Quickshell.env("HOME") + "/walls/" + win.selectedFolder)
            : Qt.resolvedUrl(Quickshell.env("HOME") + "/walls")
        showDirs: false
        showFiles: true
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
        sortField: FolderListModel.Name
    }

    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: 1220
        height: 760
        radius: 28
        color: Theme.panelBg
        border.width: 1
        border.color: Theme.border

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#8c000000"
            blurMax: 40
            shadowBlur: 1.0
            shadowVerticalOffset: 8
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 24
                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "Wallpaper & Theme"
                        color: Theme.text
                        font.family: Config.font.family
                        font.bold: true
                        font.pixelSize: 16
                    }
                    Text {
                        text: "Choose a wallpaper — the palette follows it automatically"
                        color: Theme.textFaint
                        font.family: Config.font.family
                        font.pixelSize: 12
                    }
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    width: 32; height: 32; radius: 16
                    color: closeHover.hovered ? Theme.accentSoft : Theme.borderSoft
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Text { anchors.centerIn: parent; text: "×"; color: Theme.textDim; font.family: Config.font.family; font.pixelSize: 16 }
                    HoverHandler { id: closeHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: win.cancel() }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.borderSoft }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                ColumnLayout {
                    Layout.preferredWidth: panel.width * 0.55
                    Layout.fillHeight: true
                    Layout.margins: 24
                    spacing: 14

                    Text {
                        text: "WALLPAPER"
                        color: Theme.textFaint
                        font.family: Config.font.family
                        font.pixelSize: 11
                        font.letterSpacing: 2
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        radius: 12
                        color: Theme.borderSoft
                        border.width: searchInput.activeFocus ? 1 : 0
                        border.color: Theme.accentRing

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 8

                            Icon { name: "search"; size: 14; color: Theme.textFaint }

                            TextInput {
                                id: searchInput
                                Layout.fillWidth: true
                                color: Theme.text
                                selectionColor: Theme.accent
                                clip: true
                                font.family: Config.font.family
                                font.pixelSize: 12
                                onTextChanged: win.requestSearch(text)

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: searchInput.text === ""
                                    text: "Search all wallpapers by name…"
                                    color: Theme.textFaint
                                    font.family: Config.font.family
                                    font.pixelSize: 12
                                }
                            }

                            Text {
                                visible: searchInput.text !== ""
                                text: "×"
                                color: Theme.textFaint
                                font.family: Config.font.family
                                font.pixelSize: 14
                                HoverHandler { cursorShape: Qt.PointingHandCursor }
                                TapHandler { onTapped: searchInput.text = "" }
                            }
                        }
                    }

                    Flickable {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        visible: win.searchQuery === ""
                        contentWidth: chipRow.implicitWidth
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        // Flickable only maps touch/drag flicks to scroll
                        // natively -- a plain mouse wheel does nothing on a
                        // sideways one like this without this handler.
                        WheelHandler {
                            onWheel: event => {
                                const delta = event.angleDelta.y !== 0 ? event.angleDelta.y : event.angleDelta.x
                                parent.contentX = Math.max(0, Math.min(
                                    parent.contentWidth - parent.width,
                                    parent.contentX - delta
                                ))
                            }
                        }

                        Row {
                            id: chipRow
                            spacing: 8

                            Repeater {
                                model: folders
                                delegate: Rectangle {
                                    id: chip
                                    required property string fileName
                                    width: chipLabel.implicitWidth + 24
                                    height: 30
                                    radius: 15
                                    color: win.selectedFolder === chip.fileName ? Theme.accentSoft : Theme.borderSoft
                                    border.width: (win.selectedFolder === chip.fileName || chipHover.hovered) ? 1 : 0
                                    border.color: Theme.accentRing
                                    Behavior on color { ColorAnimation { duration: 120 } }
                                    Text {
                                        id: chipLabel
                                        anchors.centerIn: parent
                                        text: chip.fileName
                                        color: (win.selectedFolder === chip.fileName || chipHover.hovered) ? Theme.accent : Theme.textDim
                                        font.family: Config.font.family
                                        font.pixelSize: 12
                                    }
                                    HoverHandler { id: chipHover; cursorShape: Qt.PointingHandCursor }
                                    TapHandler { onTapped: win.selectedFolder = chip.fileName }
                                }
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.topMargin: 20
                        visible: win.searchQuery !== "" && win.searchResults.length === 0
                        horizontalAlignment: Text.AlignHCenter
                        text: "No wallpapers match “" + win.searchQuery + "”"
                        color: Theme.textFaint
                        font.family: Config.font.family
                        font.pixelSize: 12
                    }

                    GridView {
                        id: grid
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: win.searchQuery === "" || win.searchResults.length > 0
                        clip: true
                        cellWidth: width / 3
                        cellHeight: 130
                        cacheBuffer: cellHeight * 6
                        model: win.searchQuery !== "" ? win.searchResults : images
                        delegate: Item {
                            id: tile
                            required property string fileName
                            required property string filePath
                            width: grid.cellWidth
                            height: grid.cellHeight

                            ClippingRectangle {
                                anchors.fill: parent
                                anchors.margins: 6
                                radius: 16
                                color: Theme.surface

                                HoverHandler { id: tileHover; cursorShape: Qt.PointingHandCursor }

                                Image {
                                    anchors.fill: parent
                                    asynchronous: true
                                    fillMode: Image.PreserveAspectCrop
                                    sourceSize: Qt.size(260, 160)
                                    source: Qt.resolvedUrl(tile.filePath)
                                }

                                TapHandler { onTapped: win.requestPreview(tile.filePath) }
                            }

                            // Hover/selection ring: a sibling of the card above, not
                            // a child of it -- the card clips its children, so a
                            // ring drawn there could only ever sit at or inside its
                            // edge (Rectangle.border is inset, drawn within its own
                            // bounds, never past them), overlapping the photo. This
                            // one sits further out, in the gap the card's own
                            // anchors.margins already reserves between tiles.
                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 2
                                radius: 20
                                color: "transparent"
                                border.width: (win.selectedPath === tile.filePath || tileHover.hovered) ? 2 : 0
                                border.color: win.selectedPath === tile.filePath ? Theme.accent : Theme.accentRing
                            }
                        }
                    }
                }

                Rectangle { Layout.preferredWidth: 1; Layout.fillHeight: true; color: Theme.borderSoft }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 24
                    spacing: 14

                    Text {
                        text: "THEME"
                        color: Theme.textFaint
                        font.family: Config.font.family
                        font.pixelSize: 11
                        font.letterSpacing: 2
                    }

                    RowLayout {
                        spacing: 8
                        Repeater {
                            model: [Theme.background, Theme.surface, Theme.accent, Theme.accentHover, Theme.text]
                            delegate: Rectangle {
                                required property color modelData
                                width: 26; height: 26; radius: 9
                                color: modelData
                                border.width: 1
                                border.color: Theme.borderSoft
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Repeater {
                            model: ["light", "dark"]
                            delegate: Rectangle {
                                id: seg
                                required property string modelData
                                Layout.fillWidth: true
                                height: 36
                                radius: 18
                                color: win.appearance === modelData ? Theme.accent : (segHover.hovered ? Theme.borderSoft : "transparent")
                                Behavior on color { ColorAnimation { duration: 120 } }
                                Text {
                                    anchors.centerIn: parent
                                    text: seg.modelData === "light" ? "Light" : "Dark"
                                    color: win.appearance === seg.modelData ? Theme.accentInk : Theme.textDim
                                    font.family: Config.font.family
                                    font.bold: true
                                    font.pixelSize: 12
                                }
                                HoverHandler { id: segHover; cursorShape: Qt.PointingHandCursor }
                                TapHandler { onTapped: win.appearance = seg.modelData }
                            }
                        }
                    }

                    Text {
                        Layout.topMargin: 10
                        visible: win.monitorNames.length > 1
                        text: "DISPLAY"
                        color: Theme.textFaint
                        font.family: Config.font.family
                        font.pixelSize: 11
                        font.letterSpacing: 2
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: win.monitorNames.length > 1
                        spacing: 4
                        Repeater {
                            // "both" first, then whatever hyprctl actually
                            // reports right now -- never a hardcoded name
                            // (see monitorNames' own comment on why).
                            model: [{ key: "both", label: "All displays" }].concat(
                                win.monitorNames.map(m => ({ key: m, label: m })))
                            delegate: Rectangle {
                                id: monSeg
                                required property var modelData
                                Layout.fillWidth: true
                                height: 34
                                radius: 12
                                color: win.targetMonitor === monSeg.modelData.key ? Theme.accentSoft : (monSegHover.hovered ? Theme.borderSoft : "transparent")
                                border.width: win.targetMonitor === monSeg.modelData.key ? 1 : 0
                                border.color: Theme.accentRing
                                Behavior on color { ColorAnimation { duration: 120 } }
                                Text {
                                    anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                                    text: monSeg.modelData.label
                                    color: win.targetMonitor === monSeg.modelData.key ? Theme.accent : Theme.textDim
                                    font.family: Config.font.family
                                    font.pixelSize: 12
                                }
                                HoverHandler { id: monSegHover; cursorShape: Qt.PointingHandCursor }
                                TapHandler { onTapped: win.targetMonitor = monSeg.modelData.key }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.borderSoft }

            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 18
                spacing: 10
                Item { Layout.fillWidth: true }
                Rectangle {
                    width: 90; height: 40; radius: 20
                    color: cancelHover.hovered ? Theme.accentSoft : Theme.borderSoft
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Text { anchors.centerIn: parent; text: "Cancel"; color: Theme.text; font.family: Config.font.family; font.bold: true; font.pixelSize: 13 }
                    HoverHandler { id: cancelHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: win.cancel() }
                }
                Rectangle {
                    width: 90; height: 40; radius: 20
                    color: applyHover.hovered ? Theme.accentHover : Theme.accent
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Text { anchors.centerIn: parent; text: "Apply"; color: Theme.accentInk; font.family: Config.font.family; font.bold: true; font.pixelSize: 13 }
                    HoverHandler { id: applyHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: win.apply() }
                }
            }
        }
    }
}
