# Audit — apparmor.d

Audited 2026-07-17 by nate (backfill from the original 2026-07 off-AUR vendoring).

## Upstream provenance

- **pkgver**: 0.4908.0
- **source URL**: `https://github.com/roddhjav/apparmor.d/releases/download/v0.4908.0/apparmor.d-0.4908.0.tar.gz`
- **Official channel?** Yes — `github.com/roddhjav/apparmor.d` is the upstream
  repo (Alexandre Pujol apparmor.d project; Alexandre signs releases). The
  pujol.io pubkey is referenced from pujol.io/keys.

## Integrity verification

- **GPG-signed**: `validpgpkeys=('06A26D531D56C42D66805049C5469996F0DF68EC')`
  (Alexandre Pujol's key as published on pujol.io/keys). makepkg auto-imports +
  verifies the `.asc` sidecar (`SKIP` in sha512sums because the signature is
  GPG-checked, not hash-checked).
- `sha512sums[0]` pins the tarball itself.
- This is a source build (`makedepends=(go git just)`) — the tarball is the
  Go source, NOT a prebuilt binary; the audit ceiling is high here (we build
  from upstream-tagged source, signed).

## Packaging-script review

- `build()` runs `just build=... <mode>` (default/complain and enforced
  variants) — standard Go build: `CGO_*FLAGS` plumbing, no `curl|sh`, no
  `eval`, no network in build beyond the source fetch (which makepkg sha+GPG
  verified).
- `package_apparmor.d()` and `package_apparmor.d.enforced()` install the two
  split variants into `$pkgdir` via `just ... destdir=... install`. No `$HOME`
  writes, no surprise `chmod`, no post-install hooks.

## Notes / residual risk

- Source build = we trust the Go toolchain + the upstream tag. Stronger than a
  binary-download package.
- Recurring maintenance: bump `pkgver` + `sha512sums[0]` when a new apparmor.d
  release ships; the `.asc` sha stays `SKIP` (GPG auto-verifies).