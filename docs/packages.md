# Packages

How software sources are prioritized and installed.

## Install priority

Software is installed in priority order from the first source that can
provide it. Each install is recorded in the migration that owns it.

| Tier | Source | What lives here |
|------|--------|-----------------|
| 1 | **pacman** | Arch official repos (core/extra/multilib), GPG-signed. Dominant tier. |
| 2 | **upstream release assets** | Prebuilt binaries or source tarballs published by the project itself on its GitHub/GitLab/Codeberg/etc. release page. sha256-verified against an upstream-published checksum file, GPG-verified where a release key exists (e.g. Mullvad Browser, LibreWolf, gcx, HandBrake). |
| 3 | **nix** | Local flake (`flake.nix`) wrapping nixpkgs with `allowUnfree = true`, pinned via `flake.lock`. Hermetic sandboxed builds, PR-reviewed, binary cache at cache.nixos.org. |
| 4 | **from source** | Clone the repo (or download a source tarball from the releases page) and build it. Used when no prebuilt binary is published.
| 5 | **flatpak** | Flathub. Proton Pass GUI (Proton's official Linux dist), Bottles, OrcaSlicer. |

**No AUR or yay.** Packages not in Arch official repos come from the
upstream release assets, then nix, then from source. Language runtimes
(rust, python, go, node, zig, bun) are managed globally by mise;
language-ecosystem packages (cargo, npm, pip, go, gem) are per-project only.

### nix usage

Nix itself is installed by `000011-nix` via the **upstream Nix installer**
(`releases.nixos.org`), NOT the Arch `extra/nix` pacman package -- the Arch
package links `libmimalloc` and crashes (SIGSEGV) on glibc ABI bumps. Update
nix itself with `nix upgrade-nix`; update flake packages as below.

```bash
nix profile add .#<pkg>       # install a package from the flake
nix profile upgrade --all      # upgrade all nix packages
nix flake update               # bump the nixpkgs pin (in ~/dotfiles/)
nix upgrade-nix               # upgrade nix itself (upstream installer)
```

