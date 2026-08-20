# 000207-fd.sh -- fd (pacman / apt)
# Installs: fd
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. fd is the Arch official
#       build (extra/, GPG-signed). Split out of the former 000210-cli-utilities
#       grab-bag (the apps there are independent -- not related or dependent).

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "fd"

if is_debian; then
  # Debian ships fd as 'fd-find' and installs the binary as 'fdfind' to
  # avoid a name clash with an unrelated 'fd' package. Everything here
  # (shell aliases, telescope, nvim) calls `fd`, so add a shim.
  install_apt fd-find
  if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    ok "fd -> fdfind shim in ~/.local/bin"
  fi
else
  install_pacman fd
fi

ok "fd"
