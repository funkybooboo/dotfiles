# 000222-ast-grep.sh -- ast-grep (pacman / nix)
# Installs: ast-grep
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. ast-grep is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000210-cli-utilities
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "ast-grep"

if is_debian; then
  # Not in the Ubuntu archive (or only via a third-party PPA), and no
  # upstream Linux release asset -- nixpkgs is the cross-distro source.
  install_nix .#ast-grep
else
  install_pacman ast-grep
fi

ok "ast-grep"
