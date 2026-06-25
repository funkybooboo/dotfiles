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

# UFW rules for the virbr0 bridge (only if UFW is installed). ufw is NOT
# started during migration (000405-firewall enables it without --now), so
# these rules are queued and take effect on the next boot when ufw activates.
# The rules are idempotent: ufw silently no-ops a duplicate `allow`.
if command -v ufw &>/dev/null; then
  info "adding UFW rules for libvirt (virbr0)..."
  sudo ufw allow in on virbr0 comment 'libvirt bridge' 2>/dev/null || true
  sudo ufw allow out on virbr0 2>/dev/null || true
  sudo ufw allow in on virbr0 to 192.168.122.1 port 53 proto udp \
    comment 'libvirt DNS' 2>/dev/null || true
  PRIMARY_IFACE=$(ip route 2>/dev/null | awk '/^default/{print $5; exit}')
  if [[ -n "$PRIMARY_IFACE" ]]; then
    sudo ufw route allow in on virbr0 out on "$PRIMARY_IFACE" \
      comment 'libvirt NAT' 2>/dev/null || true
    ok "UFW: libvirt virbr0 rules added (apply on next boot)"
  else
    warn "could not detect primary interface — add the UFW route rule manually"
    _add_warning "UFW libvirt NAT route rule skipped — primary interface not detected"
  fi
else
  skip "ufw not installed — libvirt firewall rules skipped"
fi
