# hosts/desktop/packages.sh — extra packages only needed on this host,
# appended to 20-packages.sh's common lists.

HOST_PACMAN_PACKAGES=(
    linux-cachyos-nvidia-open       # DKMS module for the linux-cachyos kernel
    linux-cachyos-lts-nvidia-open   # DKMS module for the LTS fallback kernel
    nvidia-utils
    nvidia-settings
    opencl-nvidia
    lib32-nvidia-utils        # 32-bit Vulkan/OpenGL (gaming)
    lib32-opencl-nvidia
    libva-nvidia-driver       # VA-API hardware video decode/encode
    linux-firmware-nvidia
)

HOST_AUR_PACKAGES=()
