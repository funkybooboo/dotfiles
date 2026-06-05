# 18-virtualization.sh — libvirt, QEMU, network, firewall

section "Virtualization"

info "installing virt-manager and dependencies..."
run_cmd sudo pacman -S --needed --noconfirm \
  libvirt virt-manager qemu-full dnsmasq edk2-ovmf swtpm
[[ $DRY_RUN -eq 0 ]] && ok "virt-manager + libvirt + QEMU"

# Enable libvirtd service + group membership
if [[ $DRY_RUN -eq 1 ]]; then
  info "would enable: libvirtd.service"
  info "would add $USER to libvirt group"
else
  if systemctl is-enabled --quiet libvirtd.service 2>/dev/null; then
    skip "libvirtd.service (already enabled)"
  else
    sudo systemctl enable --now libvirtd.service
    ok "libvirtd.service enabled"
  fi

  if systemctl is-enabled --quiet virtlogd.service 2>/dev/null; then
    skip "virtlogd.service (already enabled)"
  else
    sudo systemctl enable --now virtlogd.service
    ok "virtlogd.service enabled"
  fi

  if groups "$USER" | grep -qw libvirt; then
    skip "libvirt group (already a member)"
  else
    sudo usermod -aG libvirt "$USER"
    warn "added $USER to libvirt group — log out and back in for this to take effect"
    _add_warning "log out and back in for libvirt group membership to take effect"
  fi
fi

# Configure libvirt default network with DNS
LIBVIRT_NETWORK_XML="$DOTFILES_ROOT_ETC/libvirt/networks/default.xml"
if [[ -f "$LIBVIRT_NETWORK_XML" ]]; then
  if [[ $DRY_RUN -eq 1 ]]; then
    info "would configure libvirt default network with DNS forwarders"
  else
    if ! systemctl is-active --quiet libvirtd.service; then
      skip "libvirt default network (libvirtd not running — will be configured on first start)"
    else
      NET_INFO=$(virsh -c qemu:///system net-info default 2>/dev/null)
      if [[ -z "$NET_INFO" ]]; then
        info "configuring libvirt default network..."
        if virsh -c qemu:///system net-define "$LIBVIRT_NETWORK_XML" &>/dev/null; then
          virsh -c qemu:///system net-autostart default &>/dev/null
          virsh -c qemu:///system net-start default &>/dev/null || true
          ok "libvirt default network configured"
        else
          warn "failed to configure libvirt network — check libvirt group membership"
          _add_warning "libvirt network configuration failed — may need to log out/in for group membership"
        fi
      elif echo "$NET_INFO" | grep -q "Active:.*yes"; then
        skip "libvirt default network (already active)"
      else
        info "starting libvirt default network..."
        virsh -c qemu:///system net-start default &>/dev/null || true
        ok "libvirt default network started"
      fi
    fi
  fi
fi

# Configure UFW rules for libvirt
if command -v ufw &>/dev/null; then
  if [[ $DRY_RUN -eq 1 ]]; then
    info "would configure UFW rules for libvirt (virbr0)"
  else
    if ! sudo ufw status | grep -q "Status: active"; then
      skip "UFW firewall rules (UFW not enabled)"
    else
      info "configuring UFW firewall rules for libvirt..."

      if sudo ufw status | grep -q "Anywhere on virbr0.*ALLOW IN.*Anywhere"; then
        skip "UFW: virbr0 input rules already configured"
      else
        sudo ufw allow in on virbr0 comment 'libvirt bridge' &>/dev/null
        sudo ufw allow out on virbr0 &>/dev/null
        ok "UFW: allowed traffic on virbr0"
      fi

      if sudo ufw status | grep -q "192.168.122.1 53.*ALLOW IN"; then
        skip "UFW: DNS rule already configured"
      else
        sudo ufw allow in on virbr0 to 192.168.122.1 port 53 comment 'libvirt DNS' &>/dev/null
        ok "UFW: allowed DNS on virbr0"
      fi

      PRIMARY_IFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
      if [[ -n "$PRIMARY_IFACE" ]]; then
        if sudo ufw status | grep -q "ALLOW FWD.*Anywhere on virbr0.*Anywhere on $PRIMARY_IFACE"; then
          skip "UFW: routing rule already configured"
        else
          sudo ufw route allow in on virbr0 out on "$PRIMARY_IFACE" comment 'libvirt NAT' &>/dev/null
          ok "UFW: allowed routing virbr0 → $PRIMARY_IFACE"
        fi
      else
        warn "could not detect primary network interface — add UFW route rule manually:"
        echo -e "    ${DIM}sudo ufw route allow in on virbr0 out on <interface>${NC}"
        _add_warning "UFW routing rule not added — primary interface not detected"
      fi
    fi
  fi
else
  skip "UFW not installed — libvirt firewall rules skipped"
fi