# 000420-personal-admin-scripts.sh — personal admin/maintenance shell scripts
# Installs: —
# Links:    ~/.local/bin/{backup,btrfs-snapshot,update,update-firmware,
#             package-cleanup,clean-disk,clean-memory,cleanup-audit,
#             cleanup-system,hot-procs,gg,calendar-tui}
# Enables:  —
# Note: These are standalone personal scripts with no owning package. Some
#       depend on tools installed by other migrations (e.g. calendar-tui calls
#       calcure; btrfs-snapshot needs btrfs-progs; update-firmware needs fwupd)
#       but the scripts themselves are just linked here.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "personal admin scripts"

for _script in backup btrfs-snapshot update update-firmware package-cleanup \
  clean-disk clean-memory cleanup-audit cleanup-system hot-procs gg calendar-tui; do
  link_file "$DOTFILES_HOME/.local/bin/$_script" "$HOME/.local/bin/$_script"
done
