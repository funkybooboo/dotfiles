# 000307-librewolf-source.sh — LibreWolf from AUR source build
# Installs: librewolf (AUR source build, makepkg -si)
# Removes: nix profile librewolf (the previous install path from 000303)
# Links:   —
# Enables: —
# Note: POLICY EXCEPTION. The dotfiles no-AUR policy (2026-07-17/18) is
#       relaxed here for librewolf ONLY. The nix build of librewolf shipped
#       LibreWolf's distribution/policies layer in a way that blocked
#       extension installs; building from the AUR source package (which
#       patches firefox with the LibreWolf settings from source) is the
#       chosen fix. This is a multi-hour Firefox compile — run when you
#       have time. Switch to librewolf-bin instead if you want minutes.
#
#       Builds in ~/.cache/aur-build/librewolf (git clone of
#       https://aur.archlinux.org/librewolf.git). Idempotent: skips if
#       pacman reports librewolf installed. Non-fatal: warnings surface
#       in the migrate.sh summary on failure.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "librewolf (AUR source)"

BUILD_DIR="$HOME/.cache/aur-build/librewolf"
AUR_URL="https://aur.archlinux.org/librewolf.git"

# 1. If pacman already has librewolf, we're done (idempotent).
if pacman -Q librewolf &>/dev/null; then
  skip "librewolf (installed via pacman)"
else
  # 2. Drop the nix-installed librewolf so it doesn't ghost the AUR binary
  #    (nix profile remove is a no-op if not present). We check the profile
  #    list first to keep the output quiet + idempotent.
  if command -v nix &>/dev/null; then
    _nix_list_tmp="$(mktemp)"
    nix profile list >"$_nix_list_tmp" 2>/dev/null || true
    if grep -q "packages\.x86_64-linux\.librewolf" "$_nix_list_tmp"; then
      info "removing nix profile librewolf (superseded by AUR build)"
      if nix profile remove librewolf 2>/dev/null; then
        ok "removed nix librewolf"
      else
        warn "nix profile remove librewolf failed (continuing)"
        _add_warning "nix profile remove librewolf failed"
      fi
    fi
    rm -f "$_nix_list_tmp"
  fi

  # 3. Make sure build prerequisites exist (base-devel for makepkg, git).
  if ! command -v makepkg &>/dev/null || ! command -v git &>/dev/null; then
    install_pacman base-devel git
  fi

  # 4. Clone or update the AUR source tree.
  if [[ -d "$BUILD_DIR/.git" ]]; then
    info "updating AUR librewolf checkout"
    git -C "$BUILD_DIR" clean -xfd 2>/dev/null || true
    git -C "$BUILD_DIR" reset --hard 2>/dev/null || true
    git -C "$BUILD_DIR" pull --ff-only 2>/dev/null || \
      warn "git pull failed in $BUILD_DIR (continuing with existing tree)"
  else
    mkdir -p "$(dirname "$BUILD_DIR")"
    info "cloning $AUR_URL"
    if ! git clone "$AUR_URL" "$BUILD_DIR"; then
      warn "git clone of AUR librewolf failed"
      _add_error "AUR clone failed for librewolf"
      return 0
    fi
  fi

  # 5. Build + install. makepkg cannot run as root; migrate.sh runs as the
  #    user, so this is fine. `-si` installs the built pkg via pacman (sudo
  #    prompt is interactive). --noconfirm answers pacman's [Y/n] prompt.
  #    This is a multi-hour Firefox compile.
  info "building librewolf from source (multi-hour Firefox compile)"
  if ! ( cd "$BUILD_DIR" && makepkg -si --noconfirm --needed ); then
    warn "makepkg -si failed for librewolf"
  fi
  if pacman -Q librewolf &>/dev/null; then
    ok "librewolf installed from AUR source"
  else
    warn "makepkg -si did not result in pacman-installed librewolf"
    _add_error "librewolf AUR source build failed"
  fi
fi