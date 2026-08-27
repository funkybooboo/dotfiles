# 000406-btrfs.sh -- Btrfs tools + snapper configs + swappiness sysctl
# Installs: btrfs-progs snapper
# Deploys: /etc/sysctl.d/99-swappiness.conf
# Creates: /etc/snapper/configs/{root,home} (via snapper create-config)
# Enables:  snapper-cleanup.timer
# Note: The snapper configs are what migrate.sh's pre/post snapshots write to.
#       TIMELINE_CREATE is left at its "no" default -- these are on-demand
#       snapshots taken around a migration run, not hourly ones, so
#       snapper-timeline.timer stays disabled. snapper-cleanup.timer IS enabled
#       because the NUMBER_CLEANUP algorithm only ever runs from it.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "btrfs"

install_pacman btrfs-progs snapper

# Guarded on the config file rather than `snapper list-configs` so this stays a
# cheap file test that works before snapperd is reachable over dbus.
create_snapper_config() {
  local _cfg="$1"
  local _subvol="$2"

  if [[ -f "/etc/snapper/configs/$_cfg" ]]; then
    skip "snapper config '$_cfg' (already exists)"
    return 0
  fi

  if sudo snapper -c "$_cfg" create-config "$_subvol" 2>/dev/null; then
    ok "snapper config '$_cfg' -> $_subvol"
    return 0
  fi

  # create-config refuses when the .snapshots path it wants already exists as a
  # plain directory -- which is exactly what root/home/.local/bin/btrfs-snapshot
  # leaves behind via `mkdir -p /.snapshots`. Not auto-fixed here: the remedy
  # moves existing snapshots around, and the fstab entry that makes /.snapshots
  # a real subvolume is out of scope for migrations (README "Not deployed by
  # migrations").
  warn "could not create snapper config '$_cfg' for $_subvol"
  if [[ -d /.snapshots ]] && ! sudo btrfs subvolume show /.snapshots &>/dev/null; then
    warn "/.snapshots is a plain directory -- move it aside, then re-run"
  fi
  _add_warning "snapper config '$_cfg' not created; migrate.sh cannot snapshot $_subvol"
  return 0
}

if command -v snapper &>/dev/null; then
  create_snapper_config root /
  create_snapper_config home /home

  for _cfg in root home; do
    [[ -f "/etc/snapper/configs/$_cfg" ]] || continue

    # NUMBER_CLEANUP defaults to "no", so retention is off until set -- and the
    # algorithm only runs from snapper-cleanup.timer, so both are needed or
    # snapshots accumulate forever. NUMBER_LIMIT is trimmed from the default 50
    # to roughly ten runs' worth of pre/post pairs, since each pair diverges by
    # whatever pacman rewrote.
    _settings="NUMBER_CLEANUP=yes NUMBER_LIMIT=20"

    # SYNC_ACL is what propagates the ALLOW_USERS grant into the snapshot
    # directory ACL; without it the grant does not make `snapper -c home list`
    # readable to a non-root user.
    if [[ "$_cfg" == "home" ]]; then
      _settings="$_settings ALLOW_USERS=$(id -un) SYNC_ACL=yes"
    fi

    if sudo snapper -c "$_cfg" set-config "$_settings" 2>/dev/null; then
      ok "snapper '$_cfg' retention configured"
    else
      warn "could not configure snapper '$_cfg'"
      _add_warning "snapper set-config failed for '$_cfg'; snapshots may never be pruned"
    fi

    # Set separately so a rejection cannot take the retention keys down with it:
    # EMPTY_PRE_POST_CLEANUP is documented in snapper-configs(5) but is not among
    # the keys snapper(8) lists for set-config. It discards the empty pair an
    # already-converged re-run produces, which is the common case here.
    if ! sudo snapper -c "$_cfg" set-config "EMPTY_PRE_POST_CLEANUP=yes" 2>/dev/null; then
      warn "snapper '$_cfg': EMPTY_PRE_POST_CLEANUP not accepted (no-op runs leave empty pairs)"
      _add_warning "snapper '$_cfg' EMPTY_PRE_POST_CLEANUP unset; no-op migration runs leave empty snapshot pairs"
    fi
  done

  enable_system_service "snapper-cleanup.timer"
else
  warn "snapper not available -- skipping snapshot configuration"
  _add_warning "snapper not installed; migrate.sh will run without snapshots"
fi

deploy_etc_file "$DOTFILES_ROOT_ETC/sysctl.d/99-swappiness.conf" \
  "/etc/sysctl.d/99-swappiness.conf" 644
if command -v sysctl &>/dev/null; then
  sudo sysctl -p /etc/sysctl.d/99-swappiness.conf >/dev/null 2>&1 || true
fi
