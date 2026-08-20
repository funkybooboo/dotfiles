# 000547-discord.sh -- Discord chat client
# Installs: discord (Arch: extra/discord; Debian: upstream .deb)
# Links:   --
# Enables: --
# Note: Uses the official Arch repo package (extra/discord). The package
#       wraps the upstream AppImage and installs a desktop entry; no extra
#       config or wrapper is needed.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "discord"

if is_debian; then
  # Not in the Ubuntu archive. Upstream publishes a .deb whose download
  # endpoint redirects to the current version (tier 2).
  install_deb_url discord \
    "https://discord.com/api/download?platform=linux&format=deb" discord
else
  install_pacman discord
fi

ok "discord"