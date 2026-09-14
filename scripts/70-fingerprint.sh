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

    configure_fprintd_pam
}

# Wires pam_fprintd.so into /etc/pam.d/system-auth so a fingerprint
# authenticates SDDM login, sudo, and screen unlock alike -- system-auth is
# the common base every one of those PAM services includes on this host
# (see docs/fingerprint.md). `sufficient` as the first auth line means it's
# tried first and, on success, short-circuits the password prompt below it;
# on failure/unavailable it falls through to pam_unix as normal.
#
# `timeout=10` caps how long a login blocks waiting on a finger that never
# touches the sensor -- pam_fprintd's own default is 30s (confirmed live:
# an SDDM login with no finger placed sat on "Превышено время проверки" for
# 30s before falling through to the already-typed password), which reads as
# "the password took forever" when you just want to type normally.
configure_fprintd_pam() {
    local pam_file="/etc/pam.d/system-auth"
    local target_line='auth       sufficient                  pam_fprintd.so timeout=10'

    if grep -qF "$target_line" "$pam_file"; then
        warn "pam_fprintd.so already wired into $pam_file, skipping"
        return 0
    fi

    if grep -q 'pam_fprintd\.so' "$pam_file"; then
        info "Updating existing pam_fprintd.so line in $pam_file"
        sudo sed -i "s|^auth.*pam_fprintd\.so.*|$target_line|" "$pam_file"
    else
        info "Adding pam_fprintd.so to $pam_file"
        sudo sed -i "/^auth.*pam_faillock\.so.*preauth/i $target_line" "$pam_file"
    fi
    ok "Fingerprint auth wired into $pam_file (SDDM, sudo, screen unlock)"
}
