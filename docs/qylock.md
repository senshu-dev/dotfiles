# SDDM theming (`qylock-sddm.sh`)

A standalone CLI for managing [qylock](https://github.com/Darkkal44/qylock)
SDDM themes — not part of the automated setup, run manually:

```bash
./qylock-sddm.sh list             # list themes, marking installed/current
./qylock-sddm.sh install <theme>  # download (if needed) and activate
```

`packages` installs qylock's runtime deps (Qt6 declarative/svg/multimedia +
GStreamer plugins) unconditionally, so any theme installs and renders
without a separate dependency hunt. Per-theme fonts are a separate,
deliberately-manual step: several qylock themes bundle third-party game
fonts under their own `themes/<theme>/font/` that qylock itself doesn't
redistribute (licensing) — `qylock-sddm.sh install` prints where to drop
them after installing.
