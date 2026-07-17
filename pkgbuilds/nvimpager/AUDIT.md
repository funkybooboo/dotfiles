# Audit — nvimpager

Audited 2026-07-17 by nate (backfill from the original 2026-07 off-AUR vendoring).

## Upstream provenance

- **pkgver**: 0.13.0
- **source URL**: `https://github.com/lucc/nvimpager/archive/refs/tags/v0.13.0.tar.gz`
- **Official channel?** Yes — `github.com/lucc/nvimpager` is the upstream repo
  (lucc; the AUR maintainer is a different person but the `url=` field is
  upstream). Source tarball is GitHub's archive endpoint for the `v0.13.0` tag
  (replaces the previously AUR-flagged-out-of-date package).

## Integrity verification

- `b2sums[0]` (BLAKE2, not sha256) pins the tarball; nvimpager has no
  `validpgpkeys`; the b2sum is the integrity check.
- Source build (`makedepends=(git scdoc)`) — `package()` runs `make PREFIX=/usr
  DESTDIR=$pkgdir install`.

## Packaging-script review

- `package()`: `make ... install` (scdoc-compiled manpages + the nvimpager
  script + LICENSE). No `curl|sh`, no `eval`, no `$HOME` writes, no SUID, no
  post-install.

## Notes / residual risk

- Source build tier; very small shell+scdoc project, low attack surface.
- PKGBUILD `conflicts=(nvimpager-git)` so install_local_pkgbuild auto-evicts
  the AUR `-git` if it's installed.
- Recurring maintenance: bump `pkgver` + `b2sums[0]` when nvimpager has a new
  release (rare; this project is mature).