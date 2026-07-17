# Audit — timg

Audited 2026-07-17 by nate (backfill from the original 2026-07 off-AUR vendoring).

## Upstream provenance

- **pkgver**: 1.6.3
- **source URL**: `https://github.com/hzeller/timg/archive/v1.6.3.tar.gz`
- **Official channel?** Yes — `github.com/hzeller/timg` is the upstream repo
  (hzeller; Henner Zeller, the timg author). Source tarball is GitHub's
  archive endpoint for the `v1.6.3` tag.

## Integrity verification

- `sha256sums[0]` pins the tarball; timg has no `validpgpkeys`; pinned
  sha256 is the integrity check.
- Source build (`makedepends=(cmake pkgconf git gcc)`) — we compile the
  upstream-tagged C++ source.

## Packaging-script review

- `build()`: `cmake` + `make` (off-line cmake configure + make; packs
  `-DWITH_VIDEO_DEVICE / -DWITH_OPENSLIDE_SUPPORT / -DWITH_STB_IMAGE=Off`
  toggles). No network in build, no `curl|sh`, no `eval`.
- `package()`: `make install` into `${pkgdir}/usr`. No `$HOME` writes, no
  SUID, no post-install.

## Notes / residual risk

- Source-build tier. timg uses sccache-style makedeps; re-runs are no-op
  when pkgver is unchanged (install_local_pkgbuild's vercmp skip).
- Recurring maintenance: bump `pkgver` + `sha256sums[0]` when upstream cuts
  a new timg release (cmake project, low cadence).