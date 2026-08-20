# 000221-inotify-tools.sh -- inotify-tools (pacman / apt)
# Installs: inotify-tools
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. inotify-tools is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000210-cli-utilities
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "inotify-tools"

if is_debian; then
  install_apt inotify-tools
else
  install_pacman inotify-tools
fi

ok "inotify-tools"
