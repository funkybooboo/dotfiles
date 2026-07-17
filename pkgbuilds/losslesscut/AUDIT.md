# Audit — losslesscut-bin

Audited 2026-07-17 by nate. Drafted by `scripts/audit-aur.sh losslesscut-bin`,
then completed by human review. This is the third of the package audits
(brave + librewolf being the first two) and brings the losslesscut holdout off
the `install_aur` policy-holdout list.

## Upstream provenance

- **pkgver**: 3.69.0
- **source_x86_64** URL:
  `https://github.com/mifi/lossless-cut/releases/download/v3.69.0/LosslessCut-linux-x64.tar.bz2`
- **source_aarch64** URL:
  `https://github.com/mifi/lossless-cut/releases/download/v3.69.0/LosslessCut-linux-arm64.tar.bz2`
- **Official channel?** Yes — `github.com/mifi/lossless-cut` is the upstream
  repo (Mikael Finstad, the LosslessCut author); release tarballs are produced
  by upstream CI and uploaded to GitHub Releases. Cross-checked against the
  PKGBUILD `url`. (The original AUR PKGBUILD also fetched an `icon.svg` from
  `raw.githubusercontent.com/mifi/lossless-cut/.../src/renderer/src/icon.svg`
  at build time; we've vendored that file into this directory so `makepkg`
  fetches only the release tarball + the co-located files at build time. The
  icon.svg is sha-verified here.)

## Integrity verification (personally performed, not transitive)

Used `scripts/audit-aur.sh losslesscut-bin`, which downloaded each https source
and compared the actual sha256 against the AUR-published value:

- x86_64 release tarball: `cd69d7dda64b2978cead468c56703c1d58077e7a9c2379948a5d08816726a2e5` — matches AUR
- aarch64 release tarball: `1f4dd3e423b3888151c8a3203fcc0a4552af0538a32d88aabdc6c578e80bbd02` — matches AUR
- icon.svg: `d3d3da3f403ce1b9f846ae2a38a8fe9938fc458024352a9741b59a920eefacf9` — matches AUR (now vendored locally)
- co-located `losslesscut.desktop`: `6e14f887657ff23521cf413685ad4ac528656d8d3227c0380f5c71c30ed6ed64` — matches AUR
- co-located `LICENSE`: `48affed7162fc2e76f1cd47b50355181b869b4025ff04c2a53b03854e329dca0` — matches AUR

The co-located `losslesscut.desktop` / `LICENSE` / `icon.svg` are copied
verbatim from the AUR `losslesscut-bin` repo and committed here, so they're
tamper-evident at review time.

No `validpgpkeys` — LosslessCut does not publish GPG signatures for releases
(verified by inspecting the release page). Integrity ceiling therefore =
sha256-pinned upstream tarball (same level as the flatpak it replaces, which
verified only TLS transport).

## Packaging-script review (build/package + co-located files)

- **PKGBUILD** (derived from the AUR losslesscut-bin): `package()` switches on
  `$CARCH` (x64 / arm64), untars the release tarball into
  `/usr/share/losslesscut/`, symlinks `/usr/bin/losslesscut` -> that, then
  installs `.desktop` / `icon.svg` / `LICENSE`. No `curl|sh`, no `eval`, no
  network in build/package, no post-install hook, no `$HOME` writes, no SUSUID.
  Zero `makedepends` — it's pure-binary repackaging.
- **losslesscut.desktop** (675 bytes, vendored): standard
  `Type=Application` launcher; `Exec=losslesscut`. Inspected end-to-end; no
  `Exec=` of anything but `losslesscut`. Zen — no suspicious patterns matched.
- **LICENSE** (1071 bytes, vendored): standard MIT text. Verified readable
  text + sha256 matches AUR.
- **icon.svg** (2873 bytes, vendored): vector icon referenced by
  `Icon=losslesscut` in the .desktop. The audit confirms `file` would read it
  (SVG/text-as-XML) and sha256 matches AUR.

## Notes / residual risk

- LosslessCut is an Electron app; the prebuilt upstream tarball IS the Electron
  build (Chromium + node bundled). Its contents are NOT audited — out of scope
  for any package manager that ships Electron binaries, pacman/flatpak both
  included. The achievable ceiling is: sha256-pinned release tarball from the
  upstream's own GitHub org (this is what we have).
- This brings the `losslesscut-bin` holdout off `install_aur` and onto
  `install_local_pkgbuild` (tier: audited local PKGBUILD). With calcure the
  only remaining `install_aur` policy-holdout.
- Recurring maintenance: bump `pkgver` + the tarball entry of
  `sha256sums_x86_64`/`sha256sums_aarch64` when upstream cuts a new release.
  The co-located file shas haven't changed across many releases; they only
  move if upstream edits the .desktop/icon.
- The audit-aur.sh tool confirmed: all 4 sources cross-check OK, suspicious
  scan clean, no validpgpkeys (noted).