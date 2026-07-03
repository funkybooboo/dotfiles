# 000303-browsers.sh — web browsers + chromium flags
# Installs: firefox chromium
# Flatpak:  com.brave.Browser, io.gitlab.librewolf-community
# Links:    ~/.config/chromium-flags.conf
# Enables:  —
# Note: Brave and LibreWolf are installed from Flathub (officially maintained
#       by Brave and the LibreWolf team respectively), replacing the former
#       AUR -bin packages. The AUR -bin packages are removed after the
#       flatpaks are in place so a browser is never absent mid-swap.
#       Debug symbol packages are swept by 000550-cleanup-aur-debug.sh.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "browsers"

install_pacman firefox chromium
# Officially-maintained Flathub builds (replace AUR -bin).
install_flatpak com.brave.Browser
install_flatpak io.gitlab.librewolf-community
# Drop the superseded AUR -bin packages now that flatpaks are installed.
remove_pkg brave-bin librewolf-bin
link_file "$DOTFILES_HOME/.config/chromium-flags.conf" "$HOME/.config/chromium-flags.conf"
