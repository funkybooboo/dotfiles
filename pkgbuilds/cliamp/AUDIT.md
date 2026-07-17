# Audit — cliamp

Audited 2026-07-17 by nate (backfill from the original 2026-07 off-AUR vendoring).

## Upstream provenance

- **pkgver**: 1.57.1
- **source URL**: `https://github.com/bjarneo/cliamp/archive/refs/tags/v1.57.1.tar.gz`
- **Official channel?** Yes — `github.com/bjarneo/cliamp` is the upstream repo
  (bjarneo, the author of cliamp; the PKGBUILD maintainer field links the
  same). Source tarball is the upstream's own GitHub archive endpoint for the
  `v1.57.1` tag.

## Integrity verification

- `sha256sums[0]` pins the tarball — cliamp has no `validpgpkeys`; pinned
  sha256 is the integrity check.
- Source build (`makedepends=(go)`) — we compile the upstream-tagged Go
  source; not a prebuilt binary.

## Packaging-script review

- `build()`: plain `go build` with `CGO_ENABLED=1` + standard `-trimpath
  -buildmode=pie -ldflags=` — no remote fetch, no `curl|sh`, no `eval`.
- `package()`: installs `cliamp` to `/usr/bin`, the `.desktop`, `Cliamp.png`
  icon, and `LICENSE`. No `$HOME` writes, no SUID bits, no post-install hooks.
  (Co-located desktop/png/LICENSE audited via `scripts/audit-aur.sh cliamp`:
  no suspicious patterns matched.)

## Notes / residual risk

- Source build tier; trust = the upstream tag + sha256 pin.
- Recurring maintenance: bump `pkgver` + `sha256sums[0]` when cliamp
  releases a new version.