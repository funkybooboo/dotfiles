#!/usr/bin/env bash
# setup.sh — interactive post-reboot setup: secrets, SSH, sync, projects
#
# Run this AFTER ./migrate.sh has completed AND you have rebooted into your
# Hyprland desktop (it needs a browser for logins and network for the NAS).
#
# What it does:
#   1. Proton Pass (pass-cli) login — opens a browser
#   2. Tailscale authentication — opens a browser
#   3. NAS rsync password — pulled from Proton Pass, or prompted
#   4. secretmgr bootstrap — deploys SSH/GPG keys, injects templated configs
#   5. Agents: load SSH key into agent + prime GPG agent (passphrase prompts)
#   6. Switch dotfiles remote HTTPS -> SSH (so you can push)
#   7. Clone personal repos into ~/Projects (from ~/.config/dotfiles/projects-repos.txt)
#   8. NAS initial clone — documents, music, photos, audiobooks, books
#   9. Enable NAS sync timers
#
# This script is intentionally separate from the migrations: migrations are
# non-interactive and run in any environment (including a fresh TTY). This
# script is interactive and requires a desktop + network.

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
REPO_ROOT="$PWD"

# ---------------------------------------------------------------------------
# Logging — mirror all output to a timestamped log in logs/ (same FIFO+sed
# design as migrate.sh). Color goes to the terminal; ANSI escapes are stripped
# for a clean, grep-friendly text file.
# ---------------------------------------------------------------------------
mkdir -p "$REPO_ROOT/logs"
LOG_FILE="$REPO_ROOT/logs/setup-$(date +%Y%m%d-%H%M%S)-$$.log"
LOG_FIFO="$(mktemp -u "$REPO_ROOT/logs/.log-fifo-XXXXXX")"
mkfifo "$LOG_FIFO"
sed -E $'s/\x1b\[[0-9;]*m//g' < "$LOG_FIFO" >> "$LOG_FILE" &
LOG_STRIP_PID=$!
exec 3>&1 4>&2
exec > >(tee "$LOG_FIFO") 2>&1
trap 'exec 1>&3 2>&4 3>&- 4>&-; wait "$LOG_STRIP_PID"; rm -f "$LOG_FIFO"' EXIT
echo "=== Setup started at $(date) ==="
echo "=== Log file: $LOG_FILE ==="

# shellcheck source=migrations/_common.sh
source "$REPO_ROOT/migrations/_common.sh"

section "Post-Install Setup"

# =============================================================================
# 1. Proton Pass login
# =============================================================================

if command -v pass-cli &>/dev/null; then
  if pass-cli info &>/dev/null 2>&1; then
    skip "Proton Pass (already logged in)"
  else
    info "Proton Pass login required — opening browser for authentication..."
    echo -e "  ${DIM}Complete login in the browser, then return here.${NC}"
    pass-cli login
    ok "Proton Pass logged in"
  fi
else
  fail "pass-cli not found — run the proton-pass migration first"
  _add_error "pass-cli not installed"
fi

# =============================================================================
# 2. Tailscale authentication
# =============================================================================

if command -v tailscale &>/dev/null; then
  if tailscale status &>/dev/null; then
    skip "Tailscale (already authenticated and connected)"
  else
    info "Tailscale login required — opening browser for authentication..."
    echo -e "  ${DIM}After completing login in the browser, press Enter to continue.${NC}"
    sudo tailscale up --accept-routes
    ok "Tailscale connected"
  fi
else
  warn "tailscale not found — run the tailscale migration first"
  _add_warning "tailscale not installed; run it manually after"
fi

# Extend networkd-wait-online to also wait for tailscale0. Done here (not in a
# migration) because referencing tailscale0 before `tailscale up` has run would
# make systemd-networkd-wait-online block at boot on an interface that doesn't
# exist yet. Now that Tailscale is up, tailscale0 exists and is safe to wait on.
WAIT_ONLINE_OVERRIDE="/etc/systemd/system/systemd-networkd-wait-online.service.d/override.conf"
if [[ -f "$WAIT_ONLINE_OVERRIDE" ]] && tailscale status &>/dev/null; then
  if grep -q -- '--interface=tailscale0' "$WAIT_ONLINE_OVERRIDE" 2>/dev/null; then
    skip "wait-online override already includes tailscale0"
  else
    sudo sed -i.bak 's/\(--interface=wlan0\)[[:space:]]*$/\1 --interface=tailscale0/' "$WAIT_ONLINE_OVERRIDE"
    if grep -q -- '--interface=tailscale0' "$WAIT_ONLINE_OVERRIDE"; then
      sudo systemctl daemon-reload 2>/dev/null || true
      ok "wait-online override extended with tailscale0"
    else
      warn "failed to add tailscale0 to wait-online override — restoring backup"
      sudo cp -a "${WAIT_ONLINE_OVERRIDE}.bak" "$WAIT_ONLINE_OVERRIDE" 2>/dev/null || true
      _add_warning "wait-online override not updated with tailscale0"
    fi
  fi
fi

# =============================================================================
# 3. NAS rsync password
# =============================================================================

PASSWORD_FILE="$HOME/.config/nas-sync/rsync-password"
mkdir -p "$(dirname "$PASSWORD_FILE")"

if [[ -f "$PASSWORD_FILE" ]]; then
  skip "NAS rsync password file already exists"
else
  NAS_PASS=""
  if command -v pass-cli &>/dev/null && pass-cli info &>/dev/null 2>&1; then
    NAS_PASS=$(pass-cli item view --vault-name NAS --item-title rsync --field password 2>/dev/null || true)
  fi

  if [[ -n "$NAS_PASS" ]]; then
    printf '%s' "$NAS_PASS" > "$PASSWORD_FILE"
    chmod 600 "$PASSWORD_FILE"
    ok "NAS password set from Proton Pass"
  else
    echo ""
    echo -e "  ${BOLD}NAS rsync password${NC} (press Enter to skip):"
    read -r -s -p "  Password: " nas_password
    echo ""
    if [[ -n "$nas_password" ]]; then
      printf '%s' "$nas_password" > "$PASSWORD_FILE"
      chmod 600 "$PASSWORD_FILE"
      ok "NAS password file created: $PASSWORD_FILE"
    else
      warn "skipped password setup — create it later:"
      echo -e "    ${DIM}printf 'your_password' > $PASSWORD_FILE && chmod 600 $PASSWORD_FILE${NC}"
      _add_warning "NAS rsync password not set"
    fi
  fi
fi

# =============================================================================
# 4. secretmgr bootstrap
# =============================================================================

_SECRETMGR="$HOME/.local/bin/secretmgr"
if [[ -x "$_SECRETMGR" ]]; then
  info "Bootstrapping secrets with secretmgr..."
  "$_SECRETMGR" bootstrap
  ok "Secrets bootstrapped"
else
  warn "secretmgr not found at $_SECRETMGR — run the secretmgr migration first"
  _add_warning "secretmgr not found; run '$_SECRETMGR bootstrap' manually"
fi

# =============================================================================
# 5. Agents: load SSH key + prime GPG agent
# =============================================================================
# Two separate agents are kept (Option A: no key-material changes):
#   - OpenSSH ssh-agent holds the SSH key (~/.ssh/id_ed25519). The key is
#     passphrase-protected and the passphrase is NOT in Proton Pass, so the
#     non-interactive load done by `secretmgr bootstrap` can fail silently.
#     We load it here with a terminal passphrase prompt (ssh-add reads
#     /dev/tty).
#   - gpg-agent holds the GPG key (imported by secretmgr bootstrap). It is
#     socket-activated and prompts via pinentry-qt (GUI). We launch it and
#     prime the passphrase cache by signing a throwaway blob so that git
#     signed commits work without a prompt for the next 8h (cache-ttl).

SSH_KEY="$HOME/.ssh/id_ed25519"
GITHUB_SSH_OK=false

# ── 5a. GPG agent ──────────────────────────────────────────────────────────
# gpg-agent is socket-activated; ensure it is running, then prime the cache.
if command -v gpgconf &>/dev/null; then
  if gpg-agent --version &>/dev/null; then
    if gpgconf --launch gpg-agent 2>/dev/null; then
      ok "gpg-agent running"
    else
      # Already running is not an error — gpgconf returns nonzero in that case.
      if systemctl --user is-active gpg-agent.service &>/dev/null; then
        skip "gpg-agent (already running)"
      else
        warn "could not launch gpg-agent — git signed commits will prompt on first use"
        _add_warning "gpg-agent not launched; signing will prompt per-use"
      fi
    fi
  else
    warn "gpg-agent not found — run the gnupg migration (000404) first"
    _add_warning "gpg-agent missing; git signing will prompt per-use"
  fi
else
  warn "gpgconf not found — run the gnupg migration (000404) first"
  _add_warning "gpgconf missing; skipping GPG agent setup"
fi

# Prime the GPG passphrase cache: sign a throwaway blob. This triggers
# pinentry-qt (GUI dialog) for the GPG passphrase, which gpg-agent then caches
# for default-cache-ttl (8h). Skip if no secret key is available.
if gpg --list-secret-keys &>/dev/null; then
  if gpg --list-secret-keys &>/dev/null 2>&1 \
     && [[ -n "$(gpg --list-secret-keys --with-colons 2>/dev/null | grep '^sec')" ]]; then
    info "Priming GPG agent cache (enter GPG passphrase in the pinentry dialog)..."
    if echo "prime" | gpg --batch --yes --detach-sign --pinentry-mode loopback \
         -o /dev/null 2>/dev/null; then
      ok "GPG agent passphrase cached (8h)"
    else
      # Fall back to a pinentry-qt GUI prompt (not loopback) which is the
      # normal interactive path. This pops a dialog in Hyprland.
      if echo "prime" | gpg --batch --yes --detach-sign -o /dev/null 2>/dev/null; then
        ok "GPG agent passphrase cached (8h)"
      else
        warn "GPG agent priming failed — git signed commits will prompt on first use"
        _add_warning "GPG passphrase not cached; signing will prompt per-use"
      fi
    fi
  else
    skip "GPG agent priming (no secret key imported)"
  fi
else
  skip "GPG agent priming (gnupg not installed)"
fi

# ── 5b. SSH agent ──────────────────────────────────────────────────────────
if [[ ! -f "$SSH_KEY" ]]; then
  warn "no SSH key at $SSH_KEY — SSH-dependent steps will be skipped"
  _add_warning "SSH key missing; dotfiles remote switch and SSH project clones skipped"
else
  # Ensure the systemd ssh-agent socket is in SSH_AUTH_SOCK (it may not be set
  # in this shell if the session was started before the agent service).
  if [[ -z "${SSH_AUTH_SOCK:-}" ]] || [[ ! -S "${SSH_AUTH_SOCK:-}" ]]; then
    # The ssh-agent.service uses $XDG_RUNTIME_DIR; try the common path.
    for cand in "/run/user/$(id -u)/ssh-agent.socket" "$HOME/.ssh/ssh-agent.sock"; do
      if [[ -S "$cand" ]]; then
        export SSH_AUTH_SOCK="$cand"
        break
      fi
    done
  fi

  if ssh-add -l 2>/dev/null | grep -q 'ed25519'; then
    skip "SSH key already in agent"
  else
    info "Loading SSH key into agent (enter passphrase if prompted)..."
    if ssh-add "$SSH_KEY" </dev/tty 2>/dev/null; then
      ok "SSH key loaded into agent"
    else
      warn "could not load SSH key into agent — SSH-dependent steps will be skipped"
      _add_warning "SSH key not loaded (passphrase required?); dotfiles remote switch and SSH project clones skipped"
    fi
  fi

  # Verify GitHub SSH auth. `ssh -T git@github.com` always exits non-zero
  # (no shell access), so we check stderr for the success message.
  # StrictHostKeyChecking=accept-new auto-records github.com's host key on
  # first contact so BatchMode=yes doesn't fail on a fresh known_hosts.
  if ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new \
         -o ConnectTimeout=10 -T git@github.com 2>&1 \
      | grep -q 'successfully authenticated'; then
    GITHUB_SSH_OK=true
    ok "GitHub SSH authentication working"
  else
    warn "GitHub SSH auth failed — will use HTTPS for project clones"
    _add_warning "GitHub SSH auth failed; dotfiles remote stays HTTPS"
  fi
fi

# =============================================================================
# 6. Switch dotfiles remote HTTPS -> SSH
# =============================================================================
# So you can push changes to the dotfiles repo without HTTPS credentials.

if [[ "$GITHUB_SSH_OK" == "true" ]]; then
  _current_origin=$(git -C "$REPO_ROOT" remote get-url origin 2>/dev/null || echo "")
  if [[ "$_current_origin" == git@github.com:* ]]; then
    skip "dotfiles remote already SSH ($_current_origin)"
  elif [[ -z "$_current_origin" ]]; then
    warn "dotfiles repo has no origin remote — skipping remote switch"
  else
    _ssh_url="git@github.com:funkybooboo/dotfiles.git"
    if git -C "$REPO_ROOT" remote set-url origin "$_ssh_url"; then
      ok "dotfiles remote switched to SSH: $_ssh_url"
    else
      warn "failed to switch dotfiles remote to SSH"
      _add_warning "dotfiles remote switch failed; run: git -C ~/dotfiles remote set-url origin $_ssh_url"
    fi
  fi
else
  skip "dotfiles remote switch (SSH not ready)"
fi

# =============================================================================
# 7. Clone personal repos into ~/Projects
# =============================================================================
# Reads repo URLs from ~/.config/dotfiles/projects-repos.txt (symlinked from
# the dotfiles repo). Repos are cloned idempotently — skipped if the target
# already has a .git dir. When GitHub SSH auth works, HTTPS URLs are rewritten
# to SSH (git@github.com:...) so push works; otherwise they're cloned as-is.

PROJECTS_DIR="$HOME/Projects"
REPOS_FILE="$HOME/.config/dotfiles/projects-repos.txt"

# Link the repo-list config into ~/.config/dotfiles/.
link_file "$DOTFILES_HOME/.config/dotfiles/projects-repos.txt" "$REPOS_FILE"

# Rewrite a GitHub HTTPS URL to SSH. Other URLs are returned unchanged.
_to_ssh_url() {
  local url="$1"
  if [[ "$url" == https://github.com/* ]]; then
    local rest="${url#https://github.com/}"
    rest="${rest%.git}"
    printf 'git@github.com:%s.git\n' "$rest"
  else
    printf '%s\n' "$url"
  fi
}

if [[ ! -f "$REPOS_FILE" ]]; then
  warn "projects repo list not found at $REPOS_FILE — skipping project clones"
  _add_warning "projects-repos.txt missing; no repos cloned"
else
  mkdir -p "$PROJECTS_DIR"
  # Read non-comment, non-blank lines.
  mapfile -t _repo_urls < <(grep -vE '^\s*(#|$)' "$REPOS_FILE")

  if [[ ${#_repo_urls[@]} -eq 0 ]]; then
    skip "projects clone (no repos listed in $REPOS_FILE)"
  else
    info "${#_repo_urls[@]} repos configured in $REPOS_FILE"
    for _url in "${_repo_urls[@]}"; do
      # Trim surrounding whitespace.
      _url="${_url#"${_url%%[![:space:]]*}"}"
      _url="${_url%"${_url##*[![:space:]]}"}"
      [[ -z "$_url" ]] && continue

      # Derive directory name from the URL (last path segment, no .git).
      _name="${_url##*/}"
      _name="${_name%.git}"
      if [[ -z "$_name" ]]; then
        warn "could not parse repo name from: $_url — skipping"
        _add_warning "unparseable repo URL: $_url"
        continue
      fi

      _dest="$PROJECTS_DIR/$_name"
      if [[ -d "$_dest/.git" ]]; then
        # Second (and later) runs: refresh the cloned repo instead of skipping,
        # so re-running setup.sh keeps ~/Projects current (--ff-only is safe and
        # non-destructive; repos needing rebase are left alone and reported).
        if git -C "$_dest" pull --ff-only --quiet 2>/dev/null; then
          ok "$_name (updated)"
        else
          skip "$_name (diverged or up-to-date; left as-is)"
        fi
      else
        if [[ "$GITHUB_SSH_OK" == "true" ]]; then
          _clone_url=$(_to_ssh_url "$_url")
        else
          _clone_url="$_url"
        fi
        info "cloning $_name -> ~/Projects/$_name..."
        if git clone --quiet "$_clone_url" "$_dest"; then
          ok "$_name cloned"
        else
          warn "failed to clone $_name — continuing"
          _add_warning "project clone failed: $_name"
        fi
      fi
    done
  fi
fi

# =============================================================================
# 8. NAS initial clone
# =============================================================================

NAS_MODULES=(
  "documents:Documents"
  "music:Music"
  "photos:Photos"
  "audiobooks:Audiobooks"
  "books:Books"
)
NAS_RSYNC_BASE="rsync://funkybooboo@tnas:873/public/funkybooboo"

if [[ ! -f "$PASSWORD_FILE" ]]; then
  warn "no NAS password file — skipping initial clone"
  _add_warning "NAS initial clone skipped (no password)"
else
  info "checking NAS connectivity..."
  if "$HOME/.local/lib/check-nas-connection" 2>/dev/null; then
    ok "NAS reachable — checking for initial clone"
    for entry in "${NAS_MODULES[@]}"; do
      module="${entry%%:*}"
      local_dir="${entry##*:}"
      if [[ -d "$HOME/$local_dir" ]] && [[ -n "$(ls -A "$HOME/$local_dir" 2>/dev/null)" ]]; then
        skip "$module (already synced to ~/$local_dir)"
      else
        mkdir -p "$HOME/$local_dir"
        info "syncing $module -> ~/$local_dir..."
        if rsync -az --password-file="$PASSWORD_FILE" \
          "$NAS_RSYNC_BASE/$local_dir/" "$HOME/$local_dir/" 2>/dev/null; then
          ok "$module synced"
        else
          warn "failed to sync $module — continuing"
          _add_warning "NAS initial sync failed for: $module"
        fi
      fi
    done
  else
    warn "NAS not reachable — timers will sync automatically once it is accessible"
    _add_warning "NAS not reachable — initial clone skipped"
  fi
fi

# =============================================================================
# 9. Enable NAS sync timers (in case the nas-sync migration couldn't reach NAS)
# =============================================================================

info "ensuring NAS sync timers are enabled..."
for entry in "${NAS_MODULES[@]}"; do
  module="${entry%%:*}"
  enable_user_service "nas-sync-${module}.timer"
done

# =============================================================================
# 10. Personal repo & environment refresh
# =============================================================================
# This is the home for everything that is PERSONAL/environment-specific and
# therefore must NOT live in migrate.sh (migrate is a generic install/upgrade
# of configs and software and knows nothing about your repos, secrets, or
# containers). Re-running setup.sh keeps these current. These steps used to
# live in the retired standalone `update` script; they were moved here when
# `update` became a shim over migrate.sh. Three concerns:
#   10a. Sync GitHub forks with upstream (needs `gh` auth from step 1+).
#   10b. Update + rebuild ~/sources (personal built-from-source repos).
#   10c. Refresh running-container images (Docker/Podman).
# All idempotent and best-effort.

# ── 10a. Sync GitHub forks with upstream ─────────────────────────────────────
if command -v gh >/dev/null 2>&1; then
  _forks=$(gh repo list --fork --limit 50 --json nameWithOwner --jq '.[].nameWithOwner' 2>/dev/null || true)
  if [[ -z "$_forks" ]]; then
    skip "GitHub fork sync (no forks found)"
  else
    info "syncing ${#_forks[@]} GitHub fork(s) with upstream"
    while IFS= read -r _repo; do
      if gh repo sync "$_repo" 2>/dev/null; then
        ok "fork synced: $_repo"
      else
        warn "could not sync fork: $_repo (non-fatal)"
      fi
    done <<< "$_forks"
  fi
else
  skip "GitHub fork sync (gh not installed)"
fi

# ── 10b. Update + rebuild ~/sources ──────────────────────────────────────────
# git pull --ff-only each source repo, then run an incremental build in its
# existing build dir (ninja/cmake/go/cargo/meson/make/autotools). `sudo make
# install` re-runs for the install-target branches (idempotent for those).
_setup_build_repo() {
  local repo="$1" name
  name=$(basename "$repo")

  local ninja_dir=""
  for d in "$repo"/Build/release "$repo"/build "$repo"/Build; do
    [[ -f "$d/build.ninja" ]] && { ninja_dir="$d"; break; }
  done
  if [[ -n "$ninja_dir" ]]; then
    if ninja -C "$ninja_dir" 2>/dev/null; then ok "$name (ninja)"; return 0; else warn "$name (ninja) failed"; return 1; fi
  fi

  local cmake_make_dir=""
  for d in "$repo"/Build/release "$repo"/build "$repo"/Build; do
    [[ -f "$d/Makefile" ]] && [[ -f "$repo/CMakeLists.txt" ]] && { cmake_make_dir="$d"; break; }
  done
  if [[ -n "$cmake_make_dir" ]]; then
    if make -C "$cmake_make_dir" 2>/dev/null; then ok "$name (cmake+make)"; return 0; else warn "$name (cmake+make) failed"; return 1; fi
  fi

  if [[ -f "$repo/configure" ]] && [[ ! -f "$repo/CMakeLists.txt" ]]; then
    if [[ ! -f "$repo/build/Makefile" ]]; then
      info "$name (configure: bootstrapping build/Makefile)"
      ( cd "$repo" && ./configure --launch-jobs="$(nproc)" --launch ) >/dev/null 2>&1 || true
    fi
    if [[ -f "$repo/build/Makefile" ]]; then
      # WARNING: sudo make install runs arbitrary install targets from source repos.
      if make -C "$repo/build" 2>/dev/null && sudo make -C "$repo/build" install 2>/dev/null; then
        ok "$name (make -C build)"; return 0
      else
        warn "$name (make -C build) failed"; return 1
      fi
    fi
  fi

  if [[ -f "$repo/go.mod" ]]; then
    if (cd "$repo" && go install ./... 2>/dev/null); then ok "$name (go install)"; return 0; else warn "$name (go install) failed"; return 1; fi
  fi
  if [[ -f "$repo/Cargo.toml" ]]; then
    if (cd "$repo" && cargo build --release 2>/dev/null); then ok "$name (cargo build)"; return 0; else warn "$name (cargo build) failed"; return 1; fi
  fi
  if [[ -f "$repo/meson.build" ]]; then
    if [[ -f "$repo/builddir/build.ninja" ]] && ninja -C "$repo/builddir" 2>/dev/null; then ok "$name (meson+ninja)"; return 0; else warn "$name (meson+ninja) failed"; return 1; fi
  fi
  if [[ -f "$repo/Makefile" || -f "$repo/makefile" ]] && [[ ! -f "$repo/CMakeLists.txt" ]]; then
    if make -C "$repo" 2>/dev/null && sudo make -C "$repo" install 2>/dev/null; then ok "$name (make)"; return 0; else warn "$name (make) failed"; return 1; fi
  fi
  if [[ -f "$repo/Gemfile" ]]; then
    if (cd "$repo" && bundle install 2>/dev/null); then ok "$name (bundle)"; return 0; else warn "$name (bundle) failed"; return 1; fi
  fi
  if [[ -f "$repo/package.json" ]]; then
    if (cd "$repo" && npm install 2>/dev/null && npm run build 2>/dev/null); then ok "$name (npm)"; return 0; else warn "$name (npm) failed"; return 1; fi
  fi

  return 2
}

if [[ -d "$HOME/sources" ]]; then
  info "Updating git repos in ~/sources"
  for _repo in "$HOME/sources"/*/; do
    [[ -d "$_repo/.git" ]] || continue
    _rname=$(basename "$_repo")
    if git -C "$_repo" pull --ff-only 2>/dev/null; then
      ok "$_rname (pulled)"
    else
      warn "$_rname (diverged or error -- non-fatal)"
    fi
  done

  info "Rebuilding ~/sources repos"
  for _repo in "$HOME/sources"/*/; do
    [[ -d "$_repo/.git" ]] || continue
    _rc=0
    _setup_build_repo "$_repo" || _rc=$?
    (( _rc == 2 )) && skip "$(basename "$_repo") (no recognized build system)"
  done
else
  skip "~/sources update (directory absent)"
fi

# ── 10c. Refresh running-container images (Docker/Podman) ────────────────────
if command -v docker >/dev/null 2>&1 && sudo docker ps -q >/dev/null 2>&1; then
  info "Docker: pulling fresh images for running containers"
  for _ctr in $(sudo docker ps --format '{{.Names}}'); do
    _img=$(sudo docker inspect --format='{{.Config.Image}}' "$_ctr" 2>/dev/null || true)
    [[ -n "$_img" ]] || continue
    if sudo docker pull "$_img" 2>/dev/null; then ok "$_img ($_ctr)"; else warn "could not pull $_img (non-fatal)"; fi
  done
fi
if command -v podman >/dev/null 2>&1 && podman ps -q >/dev/null 2>&1; then
  info "Podman: pulling fresh images for running containers"
  for _ctr in $(podman ps --format '{{.Names}}'); do
    _img=$(podman inspect --format='{{.Config.Image}}' "$_ctr" 2>/dev/null || true)
    [[ -n "$_img" ]] || continue
    if podman pull "$_img" 2>/dev/null; then ok "$_img ($_ctr)"; else warn "could not pull $_img (non-fatal)"; fi
  done
fi

print_summary "secrets"
