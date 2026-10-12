# 000584-digital.sh -- Digital (nix)
# Nix:     .#digital
# Links:   --
# Enables: --
# Note: one piece of software = one migration. Digital is hneemann's digital
#       logic designer and circuit simulator (github.com/hneemann/Digital),
#       pairs with KiCad (000583) as design-then-lay-out for digital
#       electronics. Not in the Arch official repos and AUR is excluded by
#       policy, so nix (nixpkgs 0.31) is the first tier able to provide it.
#       Pure Java/Swing under XWayland -- no GL dlopen, so none of the
#       nix-on-Arch GL mismatch that killed the LocalSend nix install
#       (000582); no launch test needed beyond opening the window once.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "digital"

install_nix .#digital

ok "digital"
