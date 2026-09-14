# hosts/laptop/packages.sh — extra packages only needed on this host,
# appended to 20-packages.sh's common lists.

HOST_PACMAN_PACKAGES=(
    mbedtls      # drivers/goodix-27c6-5125: TLS-PSK to the fingerprint sensor
    opencv       # drivers/goodix-27c6-5125: SIGFM fingerprint image matching
    doctest      # drivers/goodix-27c6-5125: test framework, build dependency
    glib2-devel  # drivers/goodix-27c6-5125: glib-mkenums, needed to build its libfprint fork
)

HOST_AUR_PACKAGES=(
    enroll   # cosmic-utils/enroll: GUI for fprintd enroll/verify/delete
)
