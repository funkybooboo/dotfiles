# 000547-discord.sh -- Discord chat client (official Arch repo)
# Installs: discord (extra/discord)
# Links:   --
# Enables: --
# Note: Uses the official Arch repo package (extra/discord), not the AUR
#       -bin/-canary variants, in line with the off-AUR project. The package
#       wraps the upstream AppImage and installs a desktop entry; no extra
#       config or wrapper is needed.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "discord"

install_pacman discord

ok "discord"