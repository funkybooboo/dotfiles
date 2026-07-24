# 000303-firefox.sh -- Firefox web browser (pacman)
# Installs: firefox
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. The other browsers live in
#       000309-chromium, 000313-brave, 000307-librewolf, 000308-mullvad-browser.
#       Firefox is the Arch official build (extra/, GPG-signed).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "firefox"

install_pacman firefox

ok "firefox"