# Audit — ufw-docker

Audited 2026-07-17 by nate (backfill from the original 2026-07 off-AUR vendoring).

## Upstream provenance

- **pkgver**: 251123 (date-coded, upstream's tagging convention)
- **source URL**: `https://github.com/chaifeng/ufw-docker/archive/refs/tags/251123.tar.gz`
- **Official channel?** Yes — `github.com/chaifeng/ufw-docker` is the upstream
  repo (chaifeng, the author). Source tarball is GitHub's archive endpoint for
  the `251123` tag.

## Integrity verification

- `b2sums[0]` (BLAKE2) pins the source tarball; `b2sums[1]` pins the
  co-located `ufw-docker.install` (which is vendored alongside the PKGBUILD
  in this directory; the b2 value matches). No `validpgpkeys`; b2sums are the
  integrity checks.
- Source install (not a build; this is a single-shell-script package)— the
  script is the security tool itself.

## Packaging-script review

- `package()`: installs the upstream `ufw-docker` shell script to
  `/usr/bin/ufw-docker` + LICENSE. No `curl|sh`, no `eval`, no `$HOME` writes,
  no SUID, no remote fetch.
- `ufw-docker.install` (audited): `post_install()` only `echo`s a reminder
  to run `ufw-docker install` for the rule back-up + apply step. No code
  executes; nothing touches `$HOME`.

## Notes / residual risk

- ufw-docker is itself a shell script that patches your iptables rules; the
  trust model is "you read the script once". The upstream repo +
  b2sum-pinned tag is the audit ceiling; you can read the vendored
  `ufw-docker` script by fetching the same tarball.
- Recurring maintenance: bump `pkgver` + `b2sums[0]` when upstream cuts a new
  tag (date-coded, infrequent).