# Fingerprint driver (laptop only)

`drivers/goodix-27c6-5125` is a git submodule:
[Rockytkg/goodix-linux-27c6-5125](https://github.com/Rockytkg/goodix-linux-27c6-5125)
— a standalone userspace driver (libusb + mbedtls TLS-PSK) plus a
`libfprint` fork with SIGFM image matching, for the Goodix
`27c6:5125` USB fingerprint sensor (Honor MagicBook 14/15/16, several
Huawei MateBook models). Only relevant on `laptop` — `setup.sh fingerprint`
no-ops on any other host.

It uses the sensor's own factory firmware (`GF_ST411SEC_APP_125xx`), not a
forced flash of another Goodix variant's firmware — earlier attempts to
force-flash 51x7 firmware onto this chip corrupted the factory PSK and broke
the sensor under Windows too (see upstream issue
[#61](https://github.com/goodix-fp-linux-dev/goodix-fp-dump/issues/61)).

## Setup

```bash
./setup.sh fingerprint
```

Installs `mbedtls`/`opencv`/`doctest`/`glib2-devel` (build deps, from
`hosts/laptop/packages.sh`), builds `goodix-cli`, and runs the submodule's
own `install-goodixgf.sh` (sets up the `libfprint` driver + udev rules,
restarts `fprintd`). Safe to re-run.

**Enrolling/verifying must happen locally on the laptop, not over SSH.**
`fprintd`'s default polkit policy only authorizes the active local seat
session — an SSH session isn't one, and `fprintd-enroll` fails with
`PermissionDenied` regardless of driver state.

```bash
fprintd-enroll -f right-index-finger $USER   # don't lift your finger early —
                                              # this driver samples 3-8 dynamic
                                              # scans per enroll
fprintd-verify $USER
```

## Using it for login/sudo/unlock

`./setup.sh fingerprint` also wires `pam_fprintd.so` into
`/etc/pam.d/system-auth` (as `auth sufficient`, first line, ahead of
`pam_unix`) — every PAM service that includes it picks it up for free:
SDDM login, `sudo`, screen unlock. Idempotent, safe to re-run.

Once a finger is enrolled (see above — has to happen locally, not over
SSH), just touch the sensor at the SDDM password prompt instead of typing
— `pam_fprintd` is tried first and short-circuits the password step on a
match. The current greeter theme (`R1999_1`) doesn't render a "place your
finger" message, but the touch still authenticates.

## GUI

[`enroll`](https://aur.archlinux.org/packages/enroll) (AUR,
`cosmic-utils/enroll`) — register/verify/delete fingerprints for any user
through the same `fprintd` D-Bus API, no COSMIC session required. Installed
automatically as part of `hosts/laptop/packages.sh`.

## Tuning / debugging

- `GOODIX_DEBUG=1 fprintd-verify $USER` — logs the SIGFM match score.
  Threshold is `GF_SIGFM_SCORE_THRESHOLD=20` in the submodule's
  `src/goodixgf.c` — lower is more permissive (false accepts), higher is
  stricter (false rejects). Rebuild + rerun `./setup.sh fingerprint` after
  changing it.
- Stop `fprintd` before using `goodix-cli` directly for debugging — the
  sensor only allows one open handle (`sudo systemctl stop fprintd`).
- **Upgrading `libfprint`/`fprintd` via pacman overwrites this install** —
  rerun `./setup.sh fingerprint` afterward.

## Not usable for browser passkeys

This only integrates with PAM (`fprintd` — login, `sudo`, screen unlock).
WebAuthn/passkeys need a CTAP2/FIDO2 authenticator; Linux has no standard
platform-authenticator bridge from `libfprint` into browsers the way Windows
Hello or Touch ID work. Would need a from-scratch CTAP2 implementation on
top of this driver — out of scope here.
