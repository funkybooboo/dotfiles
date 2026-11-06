# 000411-earlyoom-tuning.sh -- keep earlyoom from executing the user session
# Installs: --
# Links:    --
# Deploys:  /etc/default/earlyoom, /etc/systemd/zram-generator.conf
# Enables:  --
#
# 000408 installed earlyoom with the stock Arch args and zram-generator
# with an untracked 4G zram0. Under the erledigen e2e stack (podman image
# builds + containers + headless chromium) the machine bottomed out RAM and
# zram at once, earlyoom hit its thresholds (mem avail AND swap free below
# 10%/5%), and then killed by oom_score one process at a time: 68 kills on
# 2026-11-06 11:43 (wireplumber, all portals, gvfs, gpg/ssh agents,
# dbus-broker, ghostty, quickshell, the test stack itself), 139 and 169 in
# the two days prior -- each wave ending in a reboot. With zram 100% full,
# every swapped-out daemon's oom_score balloons, so tiny session services
# died alongside the actual hogs.
#
# Two fixes, one mechanism each:
#   1. /etc/default/earlyoom: --avoid the session shell (bar, terminal,
#      audio, portals, agents -- avoid subtracts 300 from oom_score, it does
#      NOT exempt, so a true OOM still resolves) and --ignore-root-user
#      (the hogs on this box are user-owned: rootless podman, browsers,
#      editors). Container processes keep dying first on their own: podman
#      already sets oom_score_adj 200-300 on them.
#   2. /etc/systemd/zram-generator.conf, tracked for the first time:
#      zram-size min(ram / 2, 8192) doubles the 4G default to 8G, buying
#      headroom for the build-swap pressure that was tripping the swap
#      threshold. zram costs RAM only for the pages it holds, compressed.
#
# Both live-apply steps are idempotent: they check the running state first
# so re-runs skip. deploy_etc_file backs up the stock files to
# <dest>.bak.<ts> before overwriting.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "earlyoom + zram tuning"

deploy_etc_file \
  "$DOTFILES_ROOT_ETC/default/earlyoom" \
  "/etc/default/earlyoom" \
  644

deploy_etc_file \
  "$DOTFILES_ROOT_ETC/systemd/zram-generator.conf" \
  "/etc/systemd/zram-generator.conf" \
  644

# Grow zram0 live, BEFORE the earlyoom restart below so earlyoom's startup
# read sees the settled size (on 2026-11-06 the restart landed mid-resize
# and the startup banner printed a transient 244 MiB swap total; the poll
# loop self-corrects, but the banner misleads). The setup unit is a oneshot
# that cannot reset a device with active swap, so swapoff first (returns
# whatever zram holds back to RAM; the migration is run at the desktop,
# never mid-build, so there is headroom). 8192 MiB = 8589934592 bytes.
if [[ "$(cat /sys/block/zram0/disksize 2>/dev/null || echo 0)" == "8589934592" ]]; then
  skip "zram0 already 8G"
else
  sudo swapoff /dev/zram0 2>/dev/null || true
  if sudo systemctl restart systemd-zram-setup@zram0.service 2>/dev/null; then
    ok "zram0 re-created at 8G"
  else
    warn "could not re-create zram0 live -- 8G applies at next boot"
    _add_warning "zram0 not resized live; 8G applies at next boot"
  fi
fi

# Reload EARLYOOM_ARGS into the running earlyoom (same direct-sudo shape
# as 000011's nix-daemon restart; a restart is safe -- earlyoom holds no
# state). Skip when the running instance already has the tuned args.
if tr '\0' '\n' < "/proc/$(pidof earlyoom 2>/dev/null || echo x)/cmdline" 2>/dev/null \
   | grep -q -- --ignore-root-user; then
  skip "earlyoom already running with tuned args"
elif sudo systemctl restart earlyoom.service 2>/dev/null; then
  ok "earlyoom restarted with tuned args"
else
  warn "could not restart earlyoom -- tuned args apply after reboot"
  _add_warning "earlyoom not restarted; tuned args apply after reboot"
fi

ok "earlyoom: session shell avoided, root ignored; zram 4G -> 8G"
