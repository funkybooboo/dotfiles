# 000511-virtualization.sh — libvirt + virt-manager + QEMU + network config
# Installs: libvirt virt-manager qemu-full dnsmasq edk2-ovmf swtpm
# Deploys: /etc/libvirt/networks/default.xml, /etc/profile.d/libvirt.sh
# Links:    —
# Enables:  libvirtd.service, virtlogd.service
# Note: Adds $USER to the libvirt group (requires logout/login to take effect),
#       configures the default NAT network with DNS forwarders, and adds UFW
#       rules for the virbr0 bridge (only if UFW is enabled).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "virtualization"

install_pacman \
  libvirt virt-manager qemu-full dnsmasq edk2-ovmf swtpm

enable_system_service "libvirtd.service"
enable_system_service "virtlogd.service"

# Add user to libvirt group
if groups "$USER" | grep -qw libvirt; then
  skip "libvirt group (already a member)"
else
  if sudo usermod -aG libvirt "$USER"; then
    warn "added $USER to libvirt group — log out and back in for this to take effect"
    _add_warning "log out and back in for libvirt group membership to take effect"
  else
    warn "failed to add $USER to libvirt group"
    _add_warning "usermod -aG libvirt failed; add manually: sudo usermod -aG libvirt $USER"
  fi
fi

# libvirt default network XML + profile.d env var
deploy_etc_file "$DOTFILES_ROOT_ETC/libvirt/networks/default.xml" \
  "/etc/libvirt/networks/default.xml" 644
deploy_etc_file "$DOTFILES_ROOT_ETC/profile.d/libvirt.sh" \
  "/etc/profile.d/libvirt.sh" 644

# Configure the default network if libvirtd is running
LIBVIRT_NETWORK_XML="$DOTFILES_ROOT_ETC/libvirt/networks/default.xml"
if [[ -f "$LIBVIRT_NETWORK_XML" ]] && systemctl is-active --quiet libvirtd.service 2>/dev/null; then
  if ! virsh -c qemu:///system net-info default &>/dev/null; then
    info "configuring libvirt default network..."
    if virsh -c qemu:///system net-define "$LIBVIRT_NETWORK_XML" &>/dev/null; then
      virsh -c qemu:///system net-autostart default &>/dev/null
      virsh -c qemu:///system net-start default &>/dev/null || true
      ok "libvirt default network configured"
    else
      warn "failed to configure libvirt network — check libvirt group membership"
      _add_warning "libvirt network configuration failed — may need logout/login for group membership"
    fi
  else
    skip "libvirt default network (already defined)"
  fi
else
  skip "libvirt default network (libvirtd not running — will apply on first start)"
fi

# UFW rules for the virbr0 bridge (only if UFW is active)
if command -v ufw &>/dev/null && sudo ufw status 2>/dev/null | grep -q "Status: active"; then
  info "configuring UFW rules for libvirt (virbr0)..."
  if ! sudo ufw status | grep -q "Anywhere on virbr0.*ALLOW IN.*Anywhere"; then
    sudo ufw allow in on virbr0 comment 'libvirt bridge' &>/dev/null || true
    sudo ufw allow out on virbr0 &>/dev/null || true
    ok "UFW: allowed traffic on virbr0"
  else
    skip "UFW: virbr0 input rules already configured"
  fi
  if ! sudo ufw status | grep -q "192.168.122.1 53.*ALLOW IN"; then
    sudo ufw allow in on virbr0 to 192.168.122.1 port 53 comment 'libvirt DNS' &>/dev/null || true
    ok "UFW: allowed DNS on virbr0"
  else
    skip "UFW: DNS rule already configured"
  fi
  PRIMARY_IFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
  if [[ -n "$PRIMARY_IFACE" ]]; then
    if ! sudo ufw status | grep -q "ALLOW FWD.*Anywhere on virbr0.*Anywhere on $PRIMARY_IFACE"; then
      sudo ufw route allow in on virbr0 out on "$PRIMARY_IFACE" comment 'libvirt NAT' &>/dev/null || true
      ok "UFW: allowed routing virbr0 → $PRIMARY_IFACE"
    else
      skip "UFW: routing rule already configured"
    fi
  else
    warn "could not detect primary network interface — add UFW route rule manually"
    _add_warning "UFW routing rule not added — primary interface not detected"
  fi
else
  skip "UFW not active — libvirt firewall rules skipped"
fi
