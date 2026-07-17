# Audit — chkrootkit

Audited 2026-07-17 by nate (backfill from the original 2026-07 off-AUR vendoring).

## Upstream provenance

- **pkgver**: 0.59
- **source URL**: `ftp://ftp.chkrootkit.org/pub/seg/pac/chkrootkit-0.59.tar.gz`
- **Official channel?** Yes — `chkrootkit.org` is the upstream project's own
  site (the PKGBUILD `url`). `ftp.chkrootkit.org` is its official FTP mirror.
  Plain FTP (not HTTPS) is the only channel chkrootkit publishes — that's the
  upstream's choice, so we accept it; the sha512 below is the integrity check.

## Integrity verification

- `sha512sums[0]` pins the tarball — this is the only integrity check
  available (chkrootkit does not publish GPG signatures).
- Source build (`build() = make`) of a small C program; the source IS the
  security tool, so you read its source one time and trust the binary you
  built.

## Packaging-script review

- `build()`: `make -C $srcdir/...` — plain make, no network, no shell-out to
  remote content.
- `package()`: copies 8 compiled binaries into `/usr/lib/chkrootkit/` +
  COPYRIGHT / ACKNOWLEDGMENTS / README + a `/usr/bin/chkrootkit` symlink.
  No `curl|sh`, no `eval`, no `$HOME` writes, no post-install hooks, no
  SUID bits.

## Notes / residual risk

- chkrootkit is itself a security-audit tool; reading its source IS the
  audit trust-model (the project publishes source to read; you compile
  and run it). Source build tier, audited once.
- Recurring maintenance: bump `pkgver` + `sha512sums[0]` when
  chkrootkit.org ships a new release (rare; chkrootkit is a stable
  research tool, last release 0.59 in 2024).