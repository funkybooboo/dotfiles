# Audit — tdf

Audited 2026-07-17 by nate (backfill from the original 2026-07 off-AUR vendoring).

## Upstream provenance

- **pkgver**: 0.5.0
- **source URL**: `https://github.com/itsjunetime/tdf/archive/v0.5.0.tar.gz`
- **Official channel?** Yes — `github.com/itsjunetime/tdf` is the upstream
  repo (itsjunetime, the author). Source tarball is GitHub's archive endpoint
  for the `v0.5.0` tag.

## Integrity verification

- `sha256sums[0]` pins the tarball; tdf has no `validpgpkeys`; pinned sha256
  is the integrity check.
- Source build (`makedepends=(clang python unzip)`) — we compile the
  upstream-tagged Rust source. The build uses nightly Rust (upstream pins
  `rust-toolchain.toml = nightly`); migration 000210 provisions it via
  `rustup toolchain install nightly` (rustup is the official Rust toolchain
  manager from rust-lang.org, not a registry).

## Packaging-script review

- rustup/cargo is deliberately NOT in `makedepends` (documented in-comment):
  `makepkg -s` would otherwise `sudo pacman -S rustup` and possibly corrupt
  the mise-managed install. 000210 provisions cargo/rustup instead; build()
  uses the PATH cargo proxy from `~/.cargo/bin`. (Pattern confirmed safe
  in this package + the wayfreeze PKGBUILD.)
- `prepare()` + `build()` + `check()` + `package()`: standard offline cargo
  flow (`--frozen` honoring Cargo.lock). No `curl|sh`, no remote fetch in
  build (cargo only fetches crates during `cargo fetch --locked`, which is
  the normal crate-index trust model — crate sources are content-hashed in
  Cargo.lock). No `$HOME` writes, no SUID, no post-install.

## Notes / residual risk

- Source-build tier; trust = upstream tag + sha256 pin + rust-lang toolchain
  + Cargo.lock-pinned crate hashes.
- Recurring maintenance: bump `pkgver` + `sha256sums[0]` when upstream cuts a
  new tdf release; ensure nightly Rust is still required (re-fetch a tag
  with `rust-toolchain.toml = nightly` to be safe; 000210 handles provisioning).