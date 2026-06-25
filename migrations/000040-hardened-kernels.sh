# 000040-hardened-kernels.sh — hardened + LTS kernels, set Limine boot default
# Installs: linux-hardened linux-hardened-headers linux-lts linux-lts-headers
# Links:    —
# Enables:  —
# Depends: 000020-bootloader (Limine must be installed so /etc/default/limine exists)

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "Hardened + LTS Kernels"

install_pacman \
  linux-hardened linux-hardened-headers \
  linux-lts linux-lts-headers
ok "hardened + LTS kernels"

# Set hardened kernel as default boot entry
BOOT_ORDER_TARGET="linux-hardened, *, *fallback, Snapshots"
LIMINE_CONFIG="/etc/default/limine"

if [[ -f "$LIMINE_CONFIG" ]]; then
  if grep -q "^BOOT_ORDER=\"linux-hardened," "$LIMINE_CONFIG"; then
    skip "hardened kernel boot default (already set)"
  else
    info "setting hardened kernel as default boot entry..."
    sudo sed -i "s|^BOOT_ORDER=.*|BOOT_ORDER=\"${BOOT_ORDER_TARGET}\"|" "$LIMINE_CONFIG"
    sudo limine-update
    ok "hardened kernel set as default boot entry"
  fi
else
  warn "$LIMINE_CONFIG not found — run 000020-bootloader first"
  _add_warning "could not set hardened kernel boot default (limine config missing)"
fi
