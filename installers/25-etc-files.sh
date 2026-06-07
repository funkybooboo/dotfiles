# 25-etc-files.sh — deploy system configuration files to /etc

section "System Configuration"

# /etc/hosts
if [[ -f "$DOTFILES_ROOT_ETC/hosts" ]]; then
  HOSTS_SRC="$DOTFILES_ROOT_ETC/hosts"
  HOSTS_DEST="/etc/hosts"

  if [[ -f "$HOSTS_DEST" ]] && cmp -s "$HOSTS_SRC" "$HOSTS_DEST"; then
    skip "/etc/hosts (already up to date)"
  elif [[ $MERGE -eq 1 ]] && [[ -f "$HOSTS_DEST" ]]; then
    merge_into_src "$HOSTS_DEST" "$HOSTS_SRC"
    run_cmd sudo cp "$HOSTS_SRC" "$HOSTS_DEST"
    run_cmd sudo chown root:root "$HOSTS_DEST"
    run_cmd sudo chmod 644 "$HOSTS_DEST"
    [[ $DRY_RUN -eq 0 ]] && ok "/etc/hosts deployed (merged)"
  elif [[ $BACKUP -eq 1 ]] && [[ -f "$HOSTS_DEST" ]]; then
    hosts_bak="${HOSTS_DEST}.bak.$(date +%s)"
    info "backing up /etc/hosts → $hosts_bak"
    run_cmd sudo cp "$HOSTS_DEST" "$hosts_bak"
    run_cmd sudo cp "$HOSTS_SRC" "$HOSTS_DEST"
    run_cmd sudo chown root:root "$HOSTS_DEST"
    run_cmd sudo chmod 644 "$HOSTS_DEST"
    [[ $DRY_RUN -eq 0 ]] && ok "/etc/hosts deployed"
  elif [[ $FORCE -eq 1 ]] || [[ ! -f "$HOSTS_DEST" ]]; then
    run_cmd sudo cp "$HOSTS_SRC" "$HOSTS_DEST"
    run_cmd sudo chown root:root "$HOSTS_DEST"
    run_cmd sudo chmod 644 "$HOSTS_DEST"
    [[ $DRY_RUN -eq 0 ]] && ok "/etc/hosts deployed"
  else
    if [[ $DRY_RUN -eq 1 ]]; then
      warn "conflict: /etc/hosts already exists (content differs)"
      info "Differences:"
      diff -u "$HOSTS_DEST" "$HOSTS_SRC" 2>/dev/null | head -20 | while IFS= read -r line; do
        echo -e "    ${DIM}$line${NC}"
      done || true
      _add_warning "conflict: /etc/hosts — use --backup, --merge, or --force"
    else
      fail "/etc/hosts conflict — use --merge, --backup, or --force"
      _add_error "conflict: /etc/hosts already exists"
    fi
  fi
fi

# Power profile udev rule
UDEV_SRC="$DOTFILES_ROOT_ETC/udev/rules.d/99-power-profile.rules"
UDEV_DEST="/etc/udev/rules.d/99-power-profile.rules"
if [[ -f "$UDEV_SRC" ]]; then
  if [[ -f "$UDEV_DEST" ]] && cmp -s "$UDEV_SRC" "$UDEV_DEST"; then
    skip "power profile udev rule (already up to date)"
  elif [[ $DRY_RUN -eq 1 ]]; then
    warn "conflict: '$UDEV_DEST' already exists (content differs)"
    info "Differences:"
    diff -u "$UDEV_DEST" "$UDEV_SRC" 2>/dev/null | head -20 | while IFS= read -r line; do
      echo -e "    ${DIM}$line${NC}"
    done || true
    _add_warning "conflict: '$UDEV_DEST' — use --backup, --merge, or --force"
  else
    if sudo cp "$UDEV_SRC" "$UDEV_DEST"; then
      sudo udevadm control --reload-rules
      sudo udevadm trigger --subsystem-match=power_supply
      ok "power profile udev rule installed"
    else
      warn "failed to install udev rule — skipping"
      _add_warning "udev rule install failed: $UDEV_DEST"
    fi
  fi
fi

# Libvirt environment variable
LIBVIRT_PROFILE_SRC="$DOTFILES_ROOT_ETC/profile.d/libvirt.sh"
LIBVIRT_PROFILE_DEST="/etc/profile.d/libvirt.sh"
if [[ -f "$LIBVIRT_PROFILE_SRC" ]]; then
  if [[ -f "$LIBVIRT_PROFILE_DEST" ]] && cmp -s "$LIBVIRT_PROFILE_SRC" "$LIBVIRT_PROFILE_DEST"; then
    skip "libvirt profile.d script (already up to date)"
  elif [[ $DRY_RUN -eq 1 ]]; then
    warn "conflict: '$LIBVIRT_PROFILE_DEST' already exists (content differs)"
    info "Differences:"
    diff -u "$LIBVIRT_PROFILE_DEST" "$LIBVIRT_PROFILE_SRC" 2>/dev/null | head -20 | while IFS= read -r line; do
      echo -e "    ${DIM}$line${NC}"
    done || true
    _add_warning "conflict: '$LIBVIRT_PROFILE_DEST' — use --backup, --merge, or --force"
  else
    if sudo cp "$LIBVIRT_PROFILE_SRC" "$LIBVIRT_PROFILE_DEST"; then
      sudo chmod 644 "$LIBVIRT_PROFILE_DEST"
      ok "libvirt profile.d script installed"
    else
      warn "failed to install libvirt profile.d script — skipping"
      _add_warning "libvirt profile.d script install failed: $LIBVIRT_PROFILE_DEST"
    fi
  fi
fi

# systemd-networkd-wait-online override
NETWORKD_OVERRIDE_SRC="$DOTFILES_ROOT_ETC/systemd/system/systemd-networkd-wait-online.service.d/override.conf"
NETWORKD_OVERRIDE_DEST="/etc/systemd/system/systemd-networkd-wait-online.service.d/override.conf"
if [[ -f "$NETWORKD_OVERRIDE_SRC" ]]; then
  if [[ -f "$NETWORKD_OVERRIDE_DEST" ]] && cmp -s "$NETWORKD_OVERRIDE_SRC" "$NETWORKD_OVERRIDE_DEST"; then
    skip "networkd-wait-online override (already up to date)"
  else
    sudo mkdir -p /etc/systemd/system/systemd-networkd-wait-online.service.d
    sudo cp "$NETWORKD_OVERRIDE_SRC" "$NETWORKD_OVERRIDE_DEST"
    sudo chown root:root "$NETWORKD_OVERRIDE_DEST"
    sudo chmod 644 "$NETWORKD_OVERRIDE_DEST"
    sudo systemctl daemon-reload
    ok "networkd-wait-online override installed"
  fi
fi

# btusb modprobe config
BTUSB_MODPROBE_SRC="$DOTFILES_ROOT_ETC/modprobe.d/btusb.conf"
BTUSB_MODPROBE_DEST="/etc/modprobe.d/btusb.conf"
if [[ -f "$BTUSB_MODPROBE_SRC" ]]; then
  if [[ -f "$BTUSB_MODPROBE_DEST" ]] && cmp -s "$BTUSB_MODPROBE_SRC" "$BTUSB_MODPROBE_DEST"; then
    skip "btusb modprobe config (already up to date)"
  else
    sudo cp "$BTUSB_MODPROBE_SRC" "$BTUSB_MODPROBE_DEST"
    sudo chown root:root "$BTUSB_MODPROBE_DEST"
    sudo chmod 644 "$BTUSB_MODPROBE_DEST"
    ok "btusb modprobe config installed"
  fi
fi

# fstab (machine-specific — deploy with caution)
FSTAB_SRC="$DOTFILES_ROOT_ETC/fstab"
FSTAB_DEST="/etc/fstab"
if [[ -f "$FSTAB_SRC" ]]; then
  if [[ -f "$FSTAB_DEST" ]] && cmp -s "$FSTAB_SRC" "$FSTAB_DEST"; then
    skip "/etc/fstab (already up to date)"
  elif [[ $DRY_RUN -eq 1 ]]; then
    warn "conflict: '$FSTAB_DEST' already exists (content differs)"
    info "Differences:"
    diff -u "$FSTAB_DEST" "$FSTAB_SRC" 2>/dev/null | head -20 | while IFS= read -r line; do
      echo -e "    ${DIM}$line${NC}"
    done || true
    _add_warning "conflict: '$FSTAB_DEST' — use --backup, --merge, or --force"
  else
    if [[ $BACKUP -eq 1 ]] && [[ -f "$FSTAB_DEST" ]]; then
      fstab_bak="${FSTAB_DEST}.bak.$(date +%s)"
      info "backing up /etc/fstab → $fstab_bak"
      run_cmd sudo cp "$FSTAB_DEST" "$fstab_bak"
    fi
    run_cmd sudo cp "$FSTAB_SRC" "$FSTAB_DEST"
    ok "/etc/fstab deployed"
  fi
fi

# crypttab (machine-specific — deploy with caution)
CRYPTTAB_SRC="$DOTFILES_ROOT_ETC/crypttab"
CRYPTTAB_DEST="/etc/crypttab"
if [[ -f "$CRYPTTAB_SRC" ]]; then
  if [[ -f "$CRYPTTAB_DEST" ]] && cmp -s "$CRYPTTAB_SRC" "$CRYPTTAB_DEST"; then
    skip "/etc/crypttab (already up to date)"
  elif [[ $DRY_RUN -eq 1 ]]; then
    warn "conflict: '$CRYPTTAB_DEST' already exists (content differs)"
    info "Differences:"
    diff -u "$CRYPTTAB_DEST" "$CRYPTTAB_SRC" 2>/dev/null | head -20 | while IFS= read -r line; do
      echo -e "    ${DIM}$line${NC}"
    done || true
    _add_warning "conflict: '$CRYPTTAB_DEST' — use --backup, --merge, or --force"
  else
    if [[ $BACKUP -eq 1 ]] && [[ -f "$CRYPTTAB_DEST" ]]; then
      crypttab_bak="${CRYPTTAB_DEST}.bak.$(date +%s)"
      info "backing up /etc/crypttab → $crypttab_bak"
      run_cmd sudo cp "$CRYPTTAB_DEST" "$crypttab_bak"
    fi
    run_cmd sudo cp "$CRYPTTAB_SRC" "$CRYPTTAB_DEST"
    run_cmd sudo chmod 600 "$CRYPTTAB_DEST"
    ok "/etc/crypttab deployed"
  fi
fi

# mkinitcpio.conf (machine-specific — deploy with caution)
MKINITCPIO_SRC="$DOTFILES_ROOT_ETC/mkinitcpio.conf"
MKINITCPIO_DEST="/etc/mkinitcpio.conf"
if [[ -f "$MKINITCPIO_SRC" ]]; then
  if [[ -f "$MKINITCPIO_DEST" ]] && cmp -s "$MKINITCPIO_SRC" "$MKINITCPIO_DEST"; then
    skip "/etc/mkinitcpio.conf (already up to date)"
  elif [[ $DRY_RUN -eq 1 ]]; then
    warn "conflict: '$MKINITCPIO_DEST' already exists (content differs)"
    info "Differences:"
    diff -u "$MKINITCPIO_DEST" "$MKINITCPIO_SRC" 2>/dev/null | head -30 | while IFS= read -r line; do
      echo -e "    ${DIM}$line${NC}"
    done || true
    _add_warning "conflict: '$MKINITCPIO_DEST' — use --backup, --merge, or --force"
  else
    if [[ $BACKUP -eq 1 ]] && [[ -f "$MKINITCPIO_DEST" ]]; then
      mkinit_bak="${MKINITCPIO_DEST}.bak.$(date +%s)"
      info "backing up /etc/mkinitcpio.conf → $mkinit_bak"
      run_cmd sudo cp "$MKINITCPIO_DEST" "$mkinit_bak"
    fi
    run_cmd sudo cp "$MKINITCPIO_SRC" "$MKINITCPIO_DEST"
    ok "/etc/mkinitcpio.conf deployed"
    warn "mkinitcpio.conf changed — run 'mkinitcpio -P' to regenerate initramfs"
    _add_warning "run 'sudo mkinitcpio -P' to regenerate initramfs after mkinitcpio.conf change"
  fi
fi