# 000011-nix.sh — Nix package manager (upstream Nix installer, multi-user)
# Installs: nix via the OFFICIAL upstream installer (releases.nixos.org),
#           NOT the Arch extra/nix pacman package.
# Links:    /etc/nix/nix.conf (deploy_etc_file — flakes + nix-command)
# Enables:  nix-daemon.service (started by the installer; restarted here)
# Note: Nix is the second-tier package source per the install priority
#       (pacman -> nix -> sources -> flatpak). We install nix ITSELF from the
#       UPSTREAM installer (tier 2: upstream release asset) rather than the Arch
#       extra/nix pacman package, because the Arch package links libmimalloc as
#       a hard NEEDED lib and crashes (SIGSEGV in mimalloc's operator delete[]
#       during glibc locale-facet init) on every glibc ABI bump where Arch
#       doesn't rebuild nix+mimalloc in lockstep — see 2026-07-26 (glibc
#       2.43->2.44). The upstream installer ships its own tested binary
#       decoupled from the system glibc; nix updates come via `nix upgrade-nix`,
#       not pacman. /nix/store + nixbld users from a prior pacman nix install
#       are REUSED (the installer guards on existence), so already-installed
#       flake packages survive the swap with no re-download.
#       Idempotent: skips when /nix/var/nix/profiles/default/bin/nix works.
#       Runs after 000010 (curl/tar/xz are in base/base-devel).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "nix"

# Pinned upstream installer. The wrapper script embeds the per-arch tarball
# sha256 and verifies it before unpacking. To bump nix itself, change
# NIX_VERSION and re-run; the installer upgrades the default nix profile in
# place. After the initial install, prefer `nix upgrade-nix` for routine
# updates. Dual-arch: the wrapper selects x86_64 or aarch64 by uname.
NIX_VERSION="2.34.8"
NIX_INSTALL_URL="https://releases.nixos.org/nix/nix-${NIX_VERSION}/install"
NIX_BIN="/nix/var/nix/profiles/default/bin/nix"

# Idempotent: official nix already installed and functional -> done. Still
# re-deploy our nix.conf (cheap cmp skip when unchanged) so a hand-installed
# nix still gets the dotfiles config on the next migrate run.
if [[ -x "$NIX_BIN" ]] && "$NIX_BIN" --version &>/dev/null; then
  ok "nix (upstream installer, $("$NIX_BIN" --version 2>/dev/null | head -1))"
  deploy_etc_file "$DOTFILES_ROOT_ETC/nix/nix.conf" "/etc/nix/nix.conf" 644
  exit 0
fi

# ---------------------------------------------------------------------------
# Transition from the broken Arch extra/nix package: remove it (and sweep its
# orphaned deps mimalloc/lowdown/nix-busybox, which ONLY nix needs). pacman
# does NOT own /nix/store, so the populated store + the user's flake profile
# survive; the upstream installer reuses /nix/store. The Arch-package nixbld
# users/group, HOWEVER, are NOT reused — see the reconciliation block below.
# ---------------------------------------------------------------------------
if pacman -Q nix &>/dev/null; then
  info "removing broken Arch extra/nix (mimalloc+glibc ABI crash)"
  sudo systemctl stop nix-daemon.socket nix-daemon.service 2>/dev/null || true
  sudo systemctl disable nix-daemon.socket nix-daemon.service 2>/dev/null || true
  if sudo pacman -Rns --noconfirm nix &>/dev/null; then
    ok "removed Arch nix (mimalloc/lowdown/nix-busybox swept as orphans)"
  else
    # Fall back to a plain -R if a dep edge blocks -Rns; orphans sweep later.
    sudo pacman -R --noconfirm nix &>/dev/null || true
    warn "pacman -Rns nix failed — attempted plain -R; continuing"
    _add_warning "nix: pacman -Rns failed, used plain -R (orphan deps may remain)"
  fi
else
  skip "Arch nix not present (fresh install)"
fi

# ---------------------------------------------------------------------------
# Reconcile nixbld users/group with what the upstream installer expects.
#
# Arch's extra/nix created group `nixbld` at gid 946 + users `nixbld01..nixbld10`
# (zero-padded, uid 945..936). The upstream installer defaults to gid 30000 +
# `nixbld1..nixbld32` (no padding, uid 30001..). It BAILS on a gid mismatch
# ("the build group nixbld already exists, but with the UID 946"), and even
# NIX_BUILD_GROUP_ID=946 wouldn't fully work because the username templates
# differ (nixbld%d vs Arch's nixbld%02d) — the installer would try to create
# nixbld1..nixbld32 over the existing nixbld01..nixbld10 names and collide.
#
# Clean reproducible fix: delete the Arch-created nixbld users + group so the
# installer creates its standard 30000-range set fresh. Discrimination is by
# uid RANGE, NOT by the removal flag: Arch used uids 936..945 (all < 1000,
# system users); the upstream installer uses 30001..30032 (never < 1000). The
# ranges never overlap, so deleting nixbld users with uid < 1000 can ONLY ever
# remove Arch leftovers, never the upstream installer's set. Re-running after
# a bail still works: whether pacman nix was removed in this run or a prior
# one, leftover Arch users are caught. Once the upstream installer has run and
# NIX_BIN works, the top-of-migration idempotent skip exits before reaching
# here, so the upstream nixbld1..32 users are never touched.
#
# Safety: build users have home=/ and shell=nologin (no content to lose).
# /nix/store paths are root:nixbld; the installer re-chowns /nix to
# root:<new nixbld gid> after creating the group, so deleting the old group
# leaves no dangling ownership that matters.
# ---------------------------------------------------------------------------
_arch_nixblds=( $(getent passwd | awk -F: '$1 ~ /^nixbld[0-9]+$/ && $3 < 1000 {print $1}') )
if (( ${#_arch_nixblds[@]} > 0 )); then
  info "removing ${#_arch_nixblds[@]} Arch nixbld user(s): ${_arch_nixblds[*]}"
  for _u in "${_arch_nixblds[@]}"; do
    sudo userdel "$_u" 2>/dev/null || true
  done
  ok "removed Arch nixbld users"
fi
if getent group nixbld >/dev/null 2>&1; then
  _old_gid=$(getent group nixbld | cut -d: -f3)
  # Only remove if NOT the upstream default gid (30000) — protects a
  # completed upstream install whose binary check somehow failed this run.
  if [[ "$_old_gid" != "30000" ]]; then
    sudo groupdel nixbld 2>/dev/null || true
    ok "removed Arch nixbld group (gid $_old_gid)"
  fi
fi

# ---------------------------------------------------------------------------
# Run the upstream installer (multi-user / --daemon mode). Reuses /nix/store
# and any existing upstream nixbld users if present; creates them fresh on a
# first run. --yes: non-interactive (answers the "ready to continue" prompt).
# --no-channel-add: we use a local flake pinned via flake.lock, not channels.
# (Not --no-modify-profile: the installer setting up /etc/profile.d/nix.sh +
#  /etc/fish/conf.d/nix.fish is how nix lands on PATH for new login shells —
#  the right system-wide mechanism, and idempotent.)
# ---------------------------------------------------------------------------
if ! command -v curl &>/dev/null; then
  warn "curl missing — run 000010-base first"
  _add_warning "nix install skipped: curl unavailable"
  exit 0
fi

NIX_INSTALLER_TMP="$(mktemp)"
info "downloading upstream nix ${NIX_VERSION} installer"
if ! curl --fail --proto '=https' --tlsv1.2 -fsSL "$NIX_INSTALL_URL" -o "$NIX_INSTALLER_TMP"; then
  warn "failed to download nix installer from $NIX_INSTALL_URL"
  _add_warning "nix install failed: could not download installer"
  rm -f "$NIX_INSTALLER_TMP"
  exit 0
fi

info "running upstream nix installer (multi-user, --daemon)"
# shellcheck disable=SC1090
if sh "$NIX_INSTALLER_TMP" --daemon --yes --no-channel-add; then
  ok "nix installed via upstream installer"
else
  warn "nix upstream installer failed"
  _add_warning "nix install failed: upstream installer exited non-zero"
  rm -f "$NIX_INSTALLER_TMP"
  exit 0
fi
rm -f "$NIX_INSTALLER_TMP"

# Deploy our nix.conf (flakes + nix-command + build-users-group). The installer
# wrote a default /etc/nix/nix.conf; deploy_etc_file backs it up and overwrites.
deploy_etc_file "$DOTFILES_ROOT_ETC/nix/nix.conf" "/etc/nix/nix.conf" 644

# Restart the daemon so the experimental-features take effect.
sudo systemctl restart nix-daemon 2>/dev/null || true

# Verify.
if [[ -x "$NIX_BIN" ]] && "$NIX_BIN" --version &>/dev/null; then
  ok "nix installed ($("$NIX_BIN" --version 2>/dev/null | head -1))"
else
  warn "nix binary not functional after install — check /nix and nix-daemon"
  _add_warning "nix installed but --version failed; daemon may not be running"
fi