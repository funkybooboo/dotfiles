# 000588-nfs-utils.sh -- nfs-utils (NFS client mount helpers, pacman)
# Installs: nfs-utils
# Links:    --
# Enables:  --
# Note: one piece of software = one migration. util-linux >= 2.41 gave
#       mount(8) a native NFS path via the new kernel mount API, but
#       when the nfs-utils helper /sbin/mount.nfs is absent libmount
#       never passes the resolved server address to the kernel, and
#       the mount dies with "fsconfig() failed: NFS: mount program
#       didn't pass remote address". First hit on debbie 2026-11-22
#       running the homelab legacy extraction (read-only NFS pulls
#       from the truenas exports). Client-only: NFSv4 needs no enabled
#       services, so the shipped rpc/gssd units stay dormant.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "nfs-utils"

install_pacman nfs-utils

ok "nfs-utils"
