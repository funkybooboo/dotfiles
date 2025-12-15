# Multi-Distro Dotfiles Installation System

This installation system supports **NixOS, Ubuntu, and Arch Linux** with a unified, modular package management approach.

## Supported Distributions

- **NixOS** - Declarative configuration with bash installer guidance
- **Ubuntu/Debian** - Full automated installation
- **Arch Linux** - Full automated installation with AUR support

## Quick Start

### Full Installation (All Packages)

```bash
cd /home/nate/projects/dotfiles/install
./orchestration/install-all.sh
```

### Phased Installation (Recommended for fresh systems)

#### Pre-Reboot Phase (System packages)
```bash
./orchestration/pre-reboot.sh
# Reboot your system
```

#### Post-Reboot Phase (User packages)
```bash
./orchestration/post-reboot.sh
```

### Individual Package Installation

```bash
# Install a specific package
./packages/core/bat.sh
./packages/dev/neovim.sh
./packages/desktop/brave.sh
```

## Directory Structure

```
install/
├── lib/                      # Core libraries
│   ├── distro.sh             # Distribution detection
│   ├── package-manager.sh    # Package manager abstraction
│   └── log.sh                # Logging utilities
├── packages/                 # One installer per package (116 total)
│   ├── core/                 # Core utilities (60 packages)
│   ├── dev/                  # Development tools (35 packages)
│   ├── desktop/              # Desktop applications (18 packages)
│   └── special/              # Complex installations (18 packages)
├── orchestration/            # Installation orchestration
│   ├── install-all.sh        # Master installer
│   ├── pre-reboot.sh         # System-level phase
│   └── post-reboot.sh        # User-level phase
└── nix/                      # NixOS integration
    └── generate-packages.sh  # Auto-generate NixOS config
```

## Package Management Philosophy

### Ubuntu
- **Priority**: APT > Snap > Flatpak > Pacstall
- **Language managers**: Only when package not in above repos
- **Examples**: neovim (Pacstall), obsidian (Pacstall)

### Arch Linux
- **Priority**: pacman > AUR (yay) > language managers
- **Philosophy**: Prefer native packages over npm/cargo/go/brew
- **Examples**: lazygit (pacman), act (pacman), tealdeer (pacman)

### NixOS
- **Approach**: Declarative configuration recommended
- **Guidance**: Bash installers print what to add to configuration.nix
- **Generator**: Auto-generate package lists with `nix/generate-packages.sh`

## NixOS Integration

### Generate NixOS Configuration

```bash
./nix/generate-packages.sh
```

This creates `nix/generated-packages.nix` with all packages.

### Use Generated Config

```bash
# Copy to NixOS config directory
sudo cp nix/generated-packages.nix /etc/nixos/

# Import in configuration.nix
# Add: imports = [ ./generated-packages.nix ];

# Rebuild
sudo nixos-rebuild switch
```

## Common Operations

### Test Single Package
```bash
./packages/core/bat.sh
```

### Install Development Tools Only
```bash
for pkg in ./packages/dev/*.sh; do bash "$pkg"; done
```

### Install Desktop Applications Only
```bash
for pkg in ./packages/desktop/*.sh; do bash "$pkg"; done
```

## Troubleshooting

### Package Installation Fails

1. Check distro detection:
   ```bash
   source lib/distro.sh && echo $DISTRO
   ```

2. Run package managers installer first:
   ```bash
   ./packages/special/package-managers.sh
   ```

3. Run installer with debug:
   ```bash
   bash -x ./packages/core/bat.sh
   ```

## Package Categories

### Core (60 packages)
Command-line utilities, system tools, security tools

### Dev (35 packages)
Programming languages, build tools, version control

### Desktop (18 packages)
GUI applications, browsers, office software

### Special (18 packages)
- `package-managers.sh` - Install all package managers (**RUN FIRST**)
- `basic-system.sh` - Basic development libraries
- `container-runtime.sh` - Docker or Podman
- `cuda.sh` - NVIDIA CUDA toolkit
- `jetbrains-toolbox.sh` - JetBrains IDE manager
- And more...

## Adding New Packages

1. Create installer in appropriate category
2. Follow existing templates
3. Research package names for each distro
4. Make executable

See `/home/nate/projects/dotfiles/docs/ADDING-PACKAGES.md` for details.

## Shell Configuration

This system uses **bash** (not fish).

## Migration Notes

Old system (pre-2025) files removed:
- `installers/` → `packages/`
- `packages/packages.sh` → individual installers
- `utils/` → `lib/`

New system provides:
- ✅ One file per package (116 installers)
- ✅ Multi-distro support (NixOS, Ubuntu, Arch)
- ✅ Unified package manager interface
