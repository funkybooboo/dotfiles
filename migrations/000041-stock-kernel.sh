# 000041-stock-kernel.sh -- stock Arch linux kernel (for gaming / Steam)
# Installs: linux linux-headers
# Links:    --
# Enables:  --
# Note: This machine's default security stance (000040) is linux-hardened +
#       linux-lts, both booted with the AppArmor/LSM cmdline from 000051.
#       That hardened LSM stack breaks Steam's game<->client IPC pipe on this
#       hardware (games die at SteamAPI_Init with CCrossProcessPipe::BWrite
#       Broken pipe -- see notes). Omarchy ships the plain `linux` kernel with
#       NO apparmor/lsm cmdline and Steam works there, so this migration
#       installs the stock `linux` kernel alongside the hardened ones as a
#       gaming boot option. linux-hardened and linux-lts remain installed as
#       fallbacks; nothing is removed.
#
#       The mkinitcpio pacman hook auto-generates the UKI at
#       /boot/EFI/Linux/arch-linux.efi (same preset layout as linux-lts/
#       linux-hardened). The matching Limine boot entry in
#       /boot/limine/limine.conf is a MANUAL one-time /boot step (per the
#       convention documented in 000020/000040: migrations do not add boot
#       entries). Add it with a CLEAN cmdline (no `apparmor=1 lsm=...`) to
#       replicate the omarchy environment:
#
#           /Arch Linux (linux)
#               protocol: efi
#               path: boot():/EFI/Linux/arch-linux.efi
#               cmdline: <base cmdline from an existing entry, WITHOUT apparmor/lsm>
#
#       CAVEAT: re-running ./migrate.sh will trigger 000051-apparmor-cmdline,
#       which appends `apparmor=1 lsm=...` to every cmdline entry lacking it --
#       including this one -- re-hardening it and defeating the Steam fix. If
#       the stock kernel fixes Steam and you want it to stay unhardened, 000051
#       must be taught to skip the `arch-linux.efi` entry. That change is
#       intentionally deferred until the Steam fix is confirmed, so we do not
#       weaken the security migration on a guess.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "Stock Arch linux kernel (gaming)"

install_pacman linux linux-headers
ok "stock linux kernel (+ headers); UKI built at /boot/EFI/Linux/arch-linux.efi by mkinitcpio hook"
