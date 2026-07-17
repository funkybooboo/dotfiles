# Audit — librewolf-bin

Audited 2026-07-17 by nate, for the move from flatpak
`io.gitlab.librewolf-community` to the audited local PKGBUILD (per the user's
"everything from AUR must be packged + audited; no trust for non-official
sources" policy).

## Upstream provenance

- **pkgver**: 152.0.6_1  (Firefox 152.0.6 base, LibreWolf build 1)
- **source_x86_64 URL**:
  `https://codeberg.org/api/packages/librewolf/generic/librewolf/152.0.6-1/librewolf-152.0.6-1-linux-x86_64-package.tar.xz`
- **Official channel?** Yes — `codeberg.org/api/packages/librewolf` is the
  LibreWolf project's own binary distribution endpoint (linked from
  https://librewolf.net). Same URL the AUR `librewolf-bin` uses.
- A parallel `.sig` sidecar (`...package.tar.xz.sig`) is signed by the
  LibreWolf maintainers; GPG key id `662E3CDD6FE329002D0CA5BB40339DD82B12EF16`
  is pinned in `validpgpkeys`. makepkg auto-imports + verifies.

## Integrity verification (personally performed, not transitive)

- Downloaded `librewolf-152.0.6-1-linux-x86_64-package.tar.xz` directly.
- Computed sha256:
  `75974b75c9d8d492dd5cd742ddf3e667cb12d39ad67dcc67cb70484ccd76c9da`
- Matches the AUR `librewolf-bin` package's published `sha256sums_x86_64[0]`.
- This sha is pinned in `PKGBUILD` (`sha256sums_x86_64`).
- The `.sig` is separately verified against the pinned GPG key by makepkg
  (the 2nd `sha256sums_x86_64` entry is `SKIP` because the signature is GPG-
  checked, not hash-checked).

So integrity here is *stronger* than the flatpak it replaces — flatpak verifies
only TLS transport; this verifies sha256 + GPG signature of the publisher.

## Packaging-script review (build/package + co-located files)

- **PKGBUILD** (derived from the AUR librewolf-bin, x86_64-only):
  - `makedepends=(git)` because `source=()` includes a
    `git+https://codeberg.org/librewolf/source.git#tag=...` used to pull
    branding PNGs (16/32/.../128). Read-only; no build of firefox itself.
  - `package()`: copy the prebuilt tree into `/usr/lib/librewolf`; install
    the wrapper, .desktop, icons; symlink `libnssckbi.so` to the system NSS
    (the standard "use system certs" trick).
  - No `curl|sh`, no `eval`, no network in build/package other than the
    `git+...` source (which makepkg itself fetches and sha-validates).
- **librewolf-bin.install** (copied verbatim from AUR): `post_install`/
  `post_upgrade` only `echo` a reminder to check `.pacnew` and migrate
    overrides. No code, no $HOME writes, no services.
- **librewolf.desktop** (copied verbatim): standard Firefox-like launcher,
  `Exec=/usr/lib/librewolf/librewolf %u`. No exfil.
- **default192x192.png** (copied verbatim): `file` reports valid 192x192
  8-bit RGBA PNG; sha256 = `959c94c68cab8d5a8cff185ddf4dca92e84c18dccc6dc7c8fe11c78549cdc2f1`,
  matches AUR `sha256sums[1]`.

## Notes / residual risk

- Prebuilt firefox-binary contents NOT audited (out of scope; same as any
  binary browser package). Achievable ceiling here *is* verifiable: GPG
  signature by the LibreWolf maintainers + sha256 pin of the binary. This
  exceeds what flatpak's TLS-only transport provided.
- Recurring maintenance: bump `pkgver` (+ the `_fixedfirefoxver` /
  `_librewolfver` / `_firefoxver` derived vars — see PKGBUILD header) and
  `sha256sums_x86_64[0]` when upstream cuts a new release. The `.sig` stays
  `SKIP` (GPG-verified) so only the binary sha needs re-pinning.