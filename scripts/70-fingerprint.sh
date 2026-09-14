# 70-fingerprint.sh — Goodix 27c6:5125 fingerprint driver (laptop only).
#
# Vendored as a git submodule at drivers/goodix-27c6-5125 (Rockytkg's
# standalone libusb+mbedtls driver + a libfprint fork with SIGFM matching).
# See docs/fingerprint.md.

setup_fingerprint() {
    if [[ "$(detect_host)" != "laptop" ]]; then
        warn "Skipping fingerprint driver: laptop-only (this host is $(detect_host))"
        return 0
    fi

    local scripts_dir driver_dir
    scripts_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    driver_dir="$scripts_dir/../drivers/goodix-27c6-5125"

    info "Initializing goodix-27c6-5125 submodule"
    git -C "$scripts_dir/.." submodule update --init --recursive -- drivers/goodix-27c6-5125
    ok "Submodule ready"

    info "Building goodix-cli"
    make -C "$driver_dir" clean
    make -C "$driver_dir"
    ok "goodix-cli built"

    info "Installing libfprint driver (install-goodixgf.sh)"
    (cd "$driver_dir" && bash install-goodixgf.sh)
    ok "Fingerprint driver installed"

    warn "Enroll/verify must run locally on this machine (not over SSH) --" \
         "fprintd's polkit policy only authorizes the active local session:"
    warn "  fprintd-enroll -f right-index-finger \$USER"
    warn "  fprintd-verify \$USER"
}
