# 000225-pandoc-cli.sh -- pandoc-cli (pacman / apt)
# Installs: pandoc-cli
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. pandoc-cli is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000210-cli-utilities
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "pandoc-cli"

if is_debian; then
  # Debian ships the CLI in the plain 'pandoc' package.
  install_apt pandoc
else
  install_pacman pandoc-cli
fi

ok "pandoc-cli"
