# Audit — proton-pass-cli

Audited 2026-07-17 by nate (backfill from the original 2026-07 off-AUR vendoring; bumped 2.2.2 -> 2.2.3 with personally-computed sha256 in commit 2f1a628).

## Upstream provenance

- **pkgver**: 2.2.3 (bumped from 2.2.2 to match upstream latest, avoids a
  downgrade-on-swap with the AUR `-bin` that `yay -Syu` pre-upgrades to
  2.2.3.)
- **source URL**: `https://github.com/protonpass/pass-cli/releases/download/2.2.3/pass-cli-linux-x86_64`
- **Official channel?** Yes — `github.com/protonpass` is Proton's official
  GitHub org for the pass-cli project; `protonpass.github.io/pass-cli/` is the
  project site (the PKGBUILD `url`). Release artifacts are produced by Proton
  and uploaded to GitHub Releases.

## Integrity verification

- `sha256sums[0]` = `7188f02a7c1e79a860f7166ad2c34f7a2e6c961265b70677e2704f216dd176d9` —
  **personally computed** in commit 2f1a628 from a direct download (48139496
  bytes, HTTP 200); matches the AUR `proton-pass-cli-bin` package's published
  sha256.
- Proton's pass-cli has no `validpgpkeys` declared on the AUR; pinned sha256
  is the integrity check.
- This is a `package()`-only PKGBUILD: it just `install -Dm755`s the prebuilt
  ELF binary. The binary itself is NOT audited — out of scope for any package
  manager that ships a publisher's prebuilt ELF (pacman/flatpak both included).
  The achievable ceiling is the pinned sha256 of the publisher's own binary.

## Packaging-script review

- `package()`: one `install -Dm755` into `/usr/bin/pass-cli`. No `curl|sh`,
  no `eval`, no `$HOME` writes, no SUID, no post-install.

## Notes / residual risk

- Binary-download tier. PKGBUILD `replaces=(proton-pass-cli-bin)` +
  `conflicts=(proton-pass-cli-bin)` so install_local_pkgbuild auto-evicts the
  AUR `-bin`.
- Recurring maintenance: bump `pkgver` + `sha256sums[0]` when Proton cuts a new
  pass-cli release. The CLI is intentionally-pinned (does NOT roll forward
  via a manifest-scrape like proton-drive); bumping is a deliberate review act.