# 000238-herdr-nvim.sh -- herdr-nvim (nvim sidebar + agent annotations for herdr)
# Nix:     -- (herdr's own plugin manager; see Note)
# Links:   --
# Enables: --
# Note: one upstream repo ships two halves through different channels. The Lua
#       half (the :Herdr annotation commands) is a lazy.nvim spec at
#       root/home/.config/nvim/lua/plugins/herdr.lua, linked by 000108-neovim and
#       version-floating like every other nvim plugin here (lazy-lock.json is
#       untracked). This migration installs the OTHER half: a Rust binary
#       providing the full-height nvim sidebar and the picker over files the agent
#       touched. Installing only one half leaves the other silently missing, so
#       the two must be added and removed together.
# Note: installed with herdr's own plugin manager rather than a helper from
#       _common.sh, for two independent reasons. herdr resolves plugins through
#       its own registry at ~/.config/herdr/plugins.json, against a clone it owns
#       under ~/.config/herdr/plugins/github/, so a binary merely dropped on PATH
#       is invisible to it -- which rules out install_gh_release regardless; and
#       install_gh_release reads /releases/latest, so it could not pin a version
#       even if the registry were not a factor.
# Note: --ref pins the tag. Bare `herdr plugin install ChmaraX/herdr-nvim` floats
#       at latest, which is the same objection 000237-herdr raises against
#       upstream's install.sh ("floats at latest where flake.lock pins a
#       revision"). The pin is doubly effective here: the plugin's build hook
#       reads its download URL from the version field of the herdr-plugin.toml it
#       just checked out, so pinning the ref pins the downloaded asset too.
# Note: that build hook (`bash herdr/install.sh`) fetches the prebuilt
#       x86_64-unknown-linux-gnu asset, but falls back to `cargo build --release`
#       if the download fails and cargo is on PATH. It is: ~/.local/share/mise/
#       shims/cargo. So a transient GitHub failure does not error -- it silently
#       compiles through a mise shim, the PATH-shadowing trap the update-sources
#       notes already record. The tell is a target/ directory inside herdr's clone
#       of the plugin; a prebuilt fetch leaves none.
# Note: do NOT use `herdr plugin update`, on the same grounds as the existing
#       "do not use `herdr update`" note in 000237-herdr: a version bump is an
#       edit to _HERDR_NVIM_VERSION below, so that the installed revision is
#       recorded in git rather than in whatever the network served that day.
# Note: runs after 000237-herdr, which is what guarantees the herdr binary and its
#       user service exist first. The keybindings that reach the two plugin
#       actions live in .config/herdr/config.toml, linked by that same migration
#       -- herdr binds no plugin keys by default, so without them this installs
#       correctly and stays unreachable.
# Note: needs herdr >= 0.9.0, despite the manifest declaring min_herdr_version
#       0.7.4. Measured against 0.8.2: the annotation half works, but the sidebar
#       pane spawn fails with "Unable to spawn bin/herdr-nvim ... No viable
#       candidates found in PATH", and a 0.9.0 client refuses an 0.8.2 server
#       outright ("client protocol 22 is newer than server protocol 20"). The
#       plugin's own doctor passes every check against an isolated 0.9.0 server and
#       fails D-F7 against 0.8.2. So while herdr is pinned below 0.9.0 this
#       installs a plugin whose sidebar and picker cannot open; the fix is a
#       flake.lock bump (000600-rollforward), not a change here.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "herdr-nvim"

_HERDR_NVIM_VERSION="1.0.1"

if ! command -v herdr &>/dev/null; then
  warn "herdr not on PATH"
  _add_warning "herdr-nvim not installed; re-run once 000237-herdr lands"
# Matches the bare name rather than the chmarax.herdr-nvim plugin id: `herdr
# plugin list` is a human-facing table whose columns are not a stable contract,
# and the name appears in it either way.
elif herdr plugin list 2>/dev/null | grep -q "herdr-nvim"; then
  skip "herdr-nvim (present)"
elif run_cmd herdr plugin install "ChmaraX/herdr-nvim" \
  --ref "v$_HERDR_NVIM_VERSION" -y; then
  ok "herdr-nvim $_HERDR_NVIM_VERSION"
else
  fail "herdr plugin install failed"
  _add_error "herdr-nvim not installed; check that herdr.service is running"
fi

# Warned rather than fatal: the annotation half works fine below 0.9.0, so
# refusing the install would discard the working half to punish the broken one.
# A header comment alone would not do -- nobody reads a migration they are not
# editing, and the symptom (a keybinding that does nothing) does not name a cause.
_HERDR_NVIM_MIN_HERDR="0.9.0"
_herdr_version="$(herdr --version 2>/dev/null | awk '{print $2}')"
if [[ -n "$_herdr_version" ]] &&
  [[ "$(printf '%s\n' "$_HERDR_NVIM_MIN_HERDR" "$_herdr_version" | sort -V | head -1)" != "$_HERDR_NVIM_MIN_HERDR" ]]; then
  warn "herdr $_herdr_version predates $_HERDR_NVIM_MIN_HERDR; sidebar and picker cannot open"
  _add_warning "herdr-nvim sidebar needs herdr >= $_HERDR_NVIM_MIN_HERDR (have $_herdr_version); the 000600 roll-forward provides it"
fi
