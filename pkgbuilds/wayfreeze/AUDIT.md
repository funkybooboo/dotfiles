# Audit — wayfreeze

Audited 2026-07-17 by nate (backfill from the original 2026-07 off-AUR vendoring).

## Upstream provenance

- **pkgver**: 0.2.0
- **source URL**: `https://github.com/jappie3/wayfreeze/archive/refs/tags/0.2.0.tar.gz`
- **Official channel?** Yes — `github.com/jappie3/wayfreeze` is the upstream
  repo (jappie3, the wayfreeze author; the PKGBUILD maintains this own
  in-tree packaging off-AUR to supersede the third-party AUR `wayfreeze-git`).
  Source tarball is GitHub's archive endpoint for the `0.2.0` release tag.

## Integrity verification

- `sha256sums[0]` pins the tarball; wayfreeze has no `validpgpkeys`; pinned
  sha256 is the integrity check.
- Source build (`makedepends=(cargo)` was deliberately **removed** per commit
  ade04e4 — cargo is provided by the mise-managed rustup toolchain at
  `~/.cargo/bin`, not by a pacman package; listing it caused `makepkg -s` to
  try `sudo pacman -S cargo` mid-migration and time out the sudo prompt.
  build() uses the PATH cargo, mirroring the tdf PKGBUILD's documented
  pattern. See commit ade04e4.)

## Packaging-script review

- `build()`: `cargo build --release --frozen` with `CARGO_TARGET_DIR=target`.
  No `curl|sh`, no `eval`, no remote fetch in build (cargo only pulls crates
  during `cargo fetch`, which uses the Cargo.lock-pinned, content-hashed
  resolution model).
- `package()`: `install -Dm755 target/release/wayfreeze -> /usr/bin/wayfreeze`
  + LICENSE (with COPYING fallback). No `$HOME` writes, no SUID, no
  post-install.

## Notes / residual risk

- Source-build tier; trust = upstream tag + sha256 + Cargo.lock
  (content-hashed dependencies).
- PKGBUILD `replaces=(wayfreeze-git)` + `conflicts=(wayfreeze-git)` so
  install_local_pkgbuild auto-evicts the AUR `-git` tip package — which is
  the whole point of moving to a pinned release.
- Recurring maintenance: bump `pkgver` + `sha256sums[0]` when upstream cuts a
  new release tag.