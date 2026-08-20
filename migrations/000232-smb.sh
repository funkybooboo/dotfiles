# 000232-smb.sh -- SMB/CIFS client tooling (pacman / apt)
# Installs: gvfs-smb, smbclient, cifs-utils
# Links:    --
# Enables:  --
# Note: bundled as one migration -- these three are tightly coupled SMB/CIFS
#       client tooling (the "SMB ecosystem"), the one-ecosystem exception to
#       the one-per-software rule (like neovim/Hyprland).
#       - gvfs-smb: GVfs backend so Thunar + other GLib apps can open smb:// URIs
#         (Ctrl+L in Thunar -> smb://truenas.tail54538d.ts.net/nate).
#       - smbclient: CLI for listing/testing shares (smbclient -L //truenas -N).
#       - cifs-utils: mount(8) cifs helper for persistent fstab mounts.
#       gvfs (base) is already pulled in by 000554-thunar; this adds the SMB
#       backend so smb:// is not just a dead URI scheme.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/../_common.sh"

section "SMB/CIFS client tooling"

if is_debian; then
  # The GVfs SMB backend lives in gvfs-backends on Debian; the other two
  # keep their names.
  install_apt gvfs-backends smbclient cifs-utils
else
  install_pacman gvfs-smb
  install_pacman smbclient
  install_pacman cifs-utils
fi

ok "smb client tooling (gvfs-smb + smbclient + cifs-utils)"