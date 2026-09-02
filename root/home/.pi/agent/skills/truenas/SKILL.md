---
name: truenas
description: >
  TrueNAS Scale reference: Backblaze B2 cloud-sync backup architecture (5 snapshot
  leaf tasks), encryption facts, restore procedure, NFS/SMB/ACL permission patterns,
  midclt usage. Triggers: truenas, TrueNAS, cloud sync, cloudsync, backblaze, B2,
  rclone, crypt, restore, midclt, NFS export, maproot, root_squash, rsync permission
  denied, SMB ACL, setfacl, volume1.
---

# TrueNAS reference

## Access and management model

- `ssh root@truenas` (root SSH enabled ~2026-08-02; `nate@truenas` has no sudo;
  nate = uid 3000, in builtin_administrators). TrueNAS is an appliance -- NOT
  managed by ~/dotfiles; state changes go through `ssh root@truenas` or midclt,
  never a dotfiles migration.
- `midclt call <method>` read calls work unprivileged; `cloudsync.update <id>
  {partial dict}` is safe (won't clobber encryption_password/salt).

## B2 backup -- 5 per-LEAF snapshot tasks (replaced the old single task id=3, deleted)

| id | dataset | B2 folder prefix | schedule | excludes |
|----|---------|------------------|----------|----------|
| 4 | home/nate | /eb5fe6a2/ | Sun 00:00 | - |
| 5 | media/movies | /99f8a5b0/ | Sun 00:05 | - |
| 6 | media/tvshows | /cc810698/ | Sun 00:10 | - |
| 7 | pve/backups | /3731bd6c/ | Sun 00:15 | - |
| 8 | pve/shared | /9a8d3175/ | Sun 00:20 | /images/** |

- All: PUSH, SYNC, encryption=True + filename_encryption=True (same pw/salt as
  the old task), follow_symlinks=False, fast_list, chunk 96, transfers 8,
  snapshot=True. Only LEAF datasets support snapshot=True (nested datasets are
  rejected); TrueNAS auto-creates `cloud_sync-<id>-<ts>` ZFS snapshots and
  auto-destroys them after the run -- no manual maintenance.
- Payload ~336GiB. /pve/shared/images is excluded because sparse raw disk images
  (du says 46G) have APPARENT size 229G -- rclone uploads full apparent size and
  encryption makes the zeros incompressible. vzdump archives in pve/backups are
  the restorable form of those disks anyway.
- follow_symlinks=False is load-bearing: with True, leftover aborted-vzdump .tmp
  dirs (extracted CT rootfs full of /bin->usr/bin links) caused 7535 symlink-stat
  errors and 750x enumeration inflation (2.68M files/1.89TiB vs the real ~3.5k
  files/565GiB). For backups, ALWAYS archive the link, never dereference it.
- Encryption: contents + file names + folder names encrypted at every level.
  Visible on raw B2: only the bucket name (funkybooboo-truenas-backup) + the
  opaque 8-hex folder prefixes; object sizes +~48 bytes/file; tree depth visible.
  WITHOUT the encryption_password AND salt the data is unrecoverable -- they
  live ONLY in the TrueNAS middleware DB, not in dotfiles.
- SYNC = true mirror: locally-deleted files are removed from B2 on the next run
  (deliberate choice; retention would need COPY or --backup-dir).
- Measured ~4.3 MiB/s upstream -> first full run ~22h; weekly runs push deltas.

### Restore

rclone.conf with `[remote]` = raw B2 + `[encrypted]` = crypt overlay (pw/salt
obscured via `rclone obscure`), then per leaf:
`rclone copy encrypted:/<folder-prefix>/ /mnt/restore/`. The leaf<->prefix map
is in each task's attributes (`midclt call cloudsync.get_instance <id>`).

## NFS / SMB / ACL permission patterns

- sync-* dirs (/mnt/volume1/home/nate/{Books,Music,Audiobooks}): owner nate:nate,
  dirs 755 / files 644, default ACL `u::rwx,g::rwx,o::r-x`. WHY not 770: NFS
  readers (audiobookshelf/navidrome/omnivore, container uids 100000/100999) have
  EMPTY mapall and fall into "other" -- other must keep r-x AND the default ACL
  must stay o::r-x, or rsync-created children become NFS-invisible.
- PVE-facing NFS exports (pve/backups id=4, pve/shared id=5) need Maproot
  User=root + Maproot Group=root: default root_squash maps PVE root to nobody,
  blocking traversal of the CT .raw disks.
- CIFS client mount options (uid=1000 etc.) are view-mapping only; the server
  enforces the SMB account's server-side uid (nate=3000). "Permission denied
  (13)" from rsync over CIFS usually means the server-side uid landed in
  "other" with no write bit.