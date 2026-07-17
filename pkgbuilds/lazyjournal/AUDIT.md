# Audit — lazyjournal

Audited 2026-07-17 by nate (backfill from the original 2026-07 off-AUR vendoring).

## Upstream provenance

- **pkgver**: 0.8.6
- **source URL**: `https://github.com/Lifailon/lazyjournal/archive/refs/tags/0.8.6.tar.gz`
- **Official channel?** Yes — `github.com/Lifailon/lazyjournal` is the upstream
  repo (Lifailon, the author of lazyjournal). Source tarball is GitHub's
  archive endpoint for the `0.8.6` tag.

## Integrity verification

- `sha256sums[0]` pins the tarball; lazyjournal has no `validpgpkeys`; pinned
  sha256 is the integrity check.
- Source build (`makedepends=(go)`) — we compile from upstream-tagged Go
  source.

## Packaging-script review

- `build()` + `package()` are standard Go PKGBUILD: `go build` with `CGO_*FLAGS`
  plumbing + `GOFLAGS="-buildmode=pie -trimpath -ldflags=-linkmode=external
  -mod=readonly -modcacherw"`; installs the binary + README. No `curl|sh`,
  no `eval`, no `$HOME` writes, no SUID, no post-install.

## Notes / residual risk

- Source build tier. This PKGBUILD `replaces=(lazyjournal-bin)` + `conflicts=
  (lazyjournal-bin)`, so install_local_pkgbuild auto-evicts any AUR `-bin`.
- Recurring maintenance: bump `pkgver` + `sha256sums[0]` when upstream cuts a
  new lazyjournal release.