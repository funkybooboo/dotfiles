# 02-security-kernels.sh — hardened + LTS kernels + boot order

section "Security Kernels"

info "installing hardened kernels..."
install_pacman \
  linux-hardened linux-hardened-headers \
  linux-lts linux-lts-headers
[[ $DRY_RUN -eq 0 ]] && ok "hardened + LTS kernels" || true

# Set hardened kernel as default boot entry
BOOT_ORDER_TARGET="linux-hardened, *, *fallback, Snapshots"
LIMINE_CONFIG="/etc/default/limine"
if [[ -f "$LIMINE_CONFIG" ]]; then
  if grep -q "^BOOT_ORDER=\"linux-hardened," "$LIMINE_CONFIG"; then
    skip "hardened kernel boot default (already set)"
  elif [[ $DRY_RUN -eq 1 ]]; then
    info "would set hardened kernel as default boot entry in $LIMINE_CONFIG"
  else
    info "setting hardened kernel as default boot entry..."
    if sudo sed -i "s|^BOOT_ORDER=.*|BOOT_ORDER=\"${BOOT_ORDER_TARGET}\"|" "$LIMINE_CONFIG"; then
      sudo limine-update
      ok "hardened kernel set as default boot entry"
    else
      warn "failed to set hardened kernel as default boot entry"
      _add_warning "hardened kernel boot default configuration failed"
    fi
  fi
else
  skip "hardened kernel boot default ($LIMINE_CONFIG not found)"
fi