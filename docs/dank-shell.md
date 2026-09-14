# DankMaterialShell fork submodule

`.config/dank-shell` is a git submodule (the DankMaterialShell fork this
project is built on). After cloning or pulling this repo, run:

```bash
git submodule update --init --recursive
```

The Go daemon binary is gitignored and must be built, not copied:

```bash
cd .config/dank-shell/core && make
```

`.config/dank-shell/quickshell/DankCommon` is a symlink to `../dank-qml-common/DankCommon`
(`dank-qml-common` is a second, nested git submodule) — when deploying the
QML tree elsewhere (see below), the sibling `dank-qml-common` directory must
be copied alongside it, not just `quickshell/` alone, or that symlink dangles.

## Deployed as the live shell

The fork is deployed as the live shell: `~/.config/quickshell` is a plain
copy of `.config/dank-shell/quickshell` (plus a sibling `~/.config/dank-qml-common`,
see the symlink note above), launched directly from `~/.config/hypr/autostart.lua`
(`dms run --config ~/.config/quickshell`) rather than via the staged
`~/.config/systemd/user/dms.service` unit — that unit requires
`graphical-session.target`, which this host's systemd user session never
activates (`Requisite=graphical-session.target` fails every start; a
pre-existing gap, not something this deploy fixed).

### Rolling back the TopBar/plugins deploy

If the deployed shell misbehaves, restore the pre-deploy backup:

```bash
pkill -f 'dms run --config'   # or: kill the PID from `pgrep -f "dms run --config"`
rm -rf ~/.config/quickshell
mv ~/.config/quickshell-backup-pre-topbar-plugins-<timestamp> ~/.config/quickshell
```

Replace `<timestamp>` with the actual backup directory name
(`ls ~/.config | grep quickshell-backup-pre-topbar-plugins`). Also revert
`~/.config/hypr/autostart.lua`'s `dms run` line back to `quickshell` (or
`git checkout` that file to the pre-deploy commit) and re-run
`hyprctl reload` / restart Hyprland so the old shell relaunches on next
session start.
