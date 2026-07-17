# Audit — lazysql

Audited 2026-07-17 by nate (backfill from the original 2026-07 off-AUR vendoring; bumped 0.5.4 -> 0.5.5 with personally-computed sha256).

## Upstream provenance

- **pkgver**: 0.5.5 (bumped from 0.5.4 in commit 2f1a628 to match upstream
  latest and avoid a downgrade-on-swap when `yay -Syu` pre-upgrades the AUR
  `-bin`.)
- **source URL**: `https://github.com/jorgerojas26/lazysql/archive/refs/tags/v0.5.5.tar.gz`
- **Official channel?** Yes — `github.com/jorgerojas26/lazysql` is the
  upstream repo (jorgerojas26, the author). Source tarball is the GitHub
  archive endpoint for the `v0.5.5` tag.

## Integrity verification

- `sha256sums[0]` = `e979b86b7b40e03987d5855cece649791cf6307fc5785e1c6aac96ce6ee5135a` —
  **personally computed** (commit 2f1a628) from a direct download of the
  upstream `v0.5.5` tarball (1071016 bytes, HTTP 200); matches the AUR
  `lazysql-bin` package's published sha256 for the same source.
- lazysql has no `validpgpkeys`; pinned sha256 is the integrity check.
- Source build (`makedepends=(go)`) — Go source compiled from upstream tag.

## Packaging-script review

- `build()` + `package()` are standard Go PKGBUILD (`CGO_*FLAGS` +
  `GOFLAGS="-buildmode=pie -trimpath -ldflags=-linkmode=external"`, builds
  `./bin/$pkgname`, installs to `/usr/bin` + README). No `curl|sh`, no `eval`,
  no `$HOME` writes, no SUID, no post-install.

## Notes / residual risk

- PKGBUILD `replaces=(lazysql-bin)` + `conflicts=(lazysql-bin)` so
  install_local_pkgbuild auto-evicts the AUR `-bin`.
- Recurring maintenance: bump `pkgver` + `sha256sums[0]` when upstream cuts a
  new lazysql release. Until then re-runs of migrate are a no-op.