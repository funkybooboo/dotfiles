# Audit — brave-bin

Audited 2026-07-17 by nate, for the move from flatpak `com.brave.Browser` to
the audited local PKGBUILD (per the user's "everything from AUR must be packged
+ audited; no trust for non-official sources" policy).

## Upstream provenance

- **pkgver**: 1.92.140
- **source_x86_64 URL**:
  `https://github.com/brave/brave-browser/releases/download/v1.92.140/brave-browser-1.92.140-linux-amd64.zip`
- **Official channel?** Yes — `github.com/brave/brave-browser` is Brave
  Software's own GitHub org (`brave/brave-browser`); release artifacts are
  produced by Brave's CI and uploaded to GitHub Releases. Cross-checked
  against `https://brave.com` (the PKGBUILD `url`).

## Integrity verification (personally performed, not transitive)

- Downloaded `brave-browser-1.92.140-linux-amd64.zip` directly with `curl`.
- Computed sha256:
  `7935abc3349424ecd7d8752ae5b0dc123afda484f90e954f02e057095feff581`
- Matches the AUR `brave-bin` package's published `sha256sums_x86_64[0]`.
- This sha is pinned in `PKGBUILD` (`sha256sums_x86_64`); makepkg verifies the
  downloaded archive against it before building.

Brave does NOT publish a GPG signature for the linux-amd64 zip on GitHub
Releases (verified by inspecting the release page); the pinned sha256 is the
integrity check. (This matches the AUR package's approach — no
`validpgpkeys`.)

## Packaging-script review (build/package + co-located files)

- **PKGBUILD** (authored locally, derived from the AUR brave-bin):
  - `prepare()`: `bsdtar -xf` the zip into `brave/`, `chmod +x brave/brave`.
  - `package()`: copies `brave/` -> `/opt/brave-bin`; sets SUID on
    `chrome-sandbox` (Chrome's site-isolation sandbox helper — the SUID bit is
    required for it to do its job, no privilege escalation surface beyond
    what Chrome itself uses); installs a wrapper script + .desktop + icons +
    LICENSE.
  - No `curl|sh`, no `eval` of remote content, no network in build/package,
    no `post_install` touching `$HOME`.
- **brave-bin.sh** (the `/usr/bin/brave` wrapper, copied verbatim from AUR):
  reads `~/.config/brave-flags.conf` line-by-line into an array (skipping
  blanks/comments) and `exec`s `/opt/brave-bin/brave`. 14 lines, no
  suspicious patterns, no `eval`.
- **brave-browser.desktop** (copied verbatim): standard `Type=Application`
  desktop entry; `Exec=brave %U`. Inspected 8677 bytes (mostly localized
  GenericName/Comment strings); no `Exec=` of anything but `brave`, no
  network actions.

## Notes / residual risk

- The contents of the prebuilt Brave binary itself are NOT audited (out of
  scope for any package manager that ships a prebuilt browser binary, pacman
  included). The achievable ceiling is: pin a sha256 you personally computed
  from a download you trust (done) — which is the same level of trust flatpak
  provides via TLS transport, plus it now lives in the pacman DB and is
  reproduced identically across machines.
- Recurring maintenance: bump `pkgver` + `sha256sums_x86_64` when upstream
  releases a new version (Brave ~ weekly). Until then re-runs of migrate are
  a no-op.