# 000409-vulkan-drivers.sh -- Vulkan drivers + multilib (Intel)
# Installs: vulkan-intel lib32-vulkan-intel vulkan-icd-loader
#           lib32-vulkan-icd-loader
# Links:    --
# Enables:  --
# Note: Enables the [multilib] repo in /etc/pacman.conf (required for the
#       lib32 Vulkan/Mesa packages) before installing the Vulkan drivers.
#
#       These are the HOST Vulkan stack for both 64-bit and 32-bit:
#         64-bit (vulkan-icd-loader): Required By ffmpeg, gst-plugins-bad-libs,
#           gtk4, libplacebo, mpv (ldd confirms each links libvulkan.so.1).
#         32-bit (lib32-vulkan-icd-loader + lib32-vulkan-intel): required by
#           pacman steam (000510) -- steam hard-Depends On lib32-vulkan-driver
#           (a virtual satisfied by lib32-vulkan-intel) and lib32-vulkan-icd-
#           loader. Proton's 32-bit wine/DXVK and 32-bit games consume the
#           host 32-bit Vulkan ICD, so the 32-bit stack is NOT dead weight
#           when steam is installed from pacman (only hermetic nix steam would
#           ship its own). This is separate from 000510 so the Vulkan concern
#           (shared across host apps + steam) is owned in one place and
#           installs before steam.
#
#       Intel GPU only (this machine is Meteor Lake, single ICD). If a
#       machine has AMD/Nvidia, add the matching vulkan-*/lib32-vulkan-*
#       driver here.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "vulkan-drivers"

# Enable multilib repo if commented out (required for lib32-* Vulkan packages).
if grep -q '^#\[multilib\]' /etc/pacman.conf; then
  info "enabling multilib repository in /etc/pacman.conf..."
  if sudo sed -i '/^#\[multilib\]/,/^#Include/{s/^#//}' /etc/pacman.conf && \
     sudo pacman -Sy --noconfirm; then
    ok "multilib repository enabled"
  else
    warn "failed to enable multilib -- lib32 vulkan packages may not install"
    _add_warning "multilib repo enable failed; lib32 vulkan packages may fail"
  fi
else
  skip "multilib repository (already enabled)"
fi

install_pacman \
  vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader
ok "Vulkan drivers (Intel) -- host 64-bit + 32-bit graphics stack"
