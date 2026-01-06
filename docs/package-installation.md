# Package Installation System

## Overview
Multi-distribution package installation system that supports Arch Linux, Ubuntu/Debian, and NixOS. The system provides 116+ automated installers organized by category, with a unified interface across different package managers.

## Quick Reference

### Install All Packages
```bash
cd ~/dotfiles/install
./orchestration/install-all.sh
```

### Install Specific Category
```bash
# Core utilities
for pkg in ./packages/core/*.sh; do bash "$pkg"; done

# Development tools
for pkg in ./packages/dev/*.sh; do bash "$pkg"; done

# Desktop applications
for pkg in ./packages/desktop/*.sh; do bash "$pkg"; done

# Fonts
for pkg in ./packages/fonts/*.sh; do bash "$pkg"; done
```

### Install Individual Package
```bash
cd ~/dotfiles/install
./packages/core/bat.sh
./packages/dev/neovim.sh
./packages/desktop/brave.sh
```

## Installation Methods

### Method 1: Full Installation (All Packages)
Installs all 116+ packages in one go. Use this for setting up a new system quickly.

```bash
cd ~/dotfiles/install
./orchestration/install-all.sh
```

**Duration:** 30-60 minutes depending on internet speed and system

**What it installs:**
- Core utilities (60+ packages)
- Development tools (35+ packages)
- Desktop applications (18+ packages)
- Fonts (5+ packages)
- Special packages (18+ packages)

### Method 2: Phased Installation (Recommended for Fresh Systems)
Split installation into two phases: before and after a system reboot. This is safer for fresh system setups.

#### Phase 1: Pre-Reboot (System-Level Packages)
```bash
cd ~/dotfiles/install
./orchestration/pre-reboot.sh
```

**Then reboot your system:**
```bash
sudo reboot
```

#### Phase 2: Post-Reboot (User-Level Packages)
```bash
cd ~/dotfiles/install
./orchestration/post-reboot.sh
```

**When to use this method:**
- Fresh OS installation
- Major system updates
- Installing kernel modules or drivers
- Installing display managers or desktop environments

### Method 3: Category-Based Installation
Install packages by category based on your needs.

```bash
cd ~/dotfiles/install/packages

# Core utilities (bat, eza, fd, ripgrep, etc.)
for pkg in core/*.sh; do bash "$pkg"; done

# Development tools (git, neovim, docker, languages, etc.)
for pkg in dev/*.sh; do bash "$pkg"; done

# Desktop apps (browsers, Spotify, Discord, etc.)
for pkg in desktop/*.sh; do bash "$pkg"; done

# Fonts (JetBrains Mono, Nerd Fonts, etc.)
for pkg in fonts/*.sh; do bash "$pkg"; done

# Special packages (CUDA, Jetbrains Toolbox, etc.)
for pkg in special/*.sh; do bash "$pkg"; done
```

### Method 4: Individual Package Installation
Install specific packages one at a time.

```bash
cd ~/dotfiles/install

# Examples
./packages/core/bat.sh           # Better cat
./packages/core/eza.sh           # Better ls
./packages/core/ripgrep.sh       # Better grep
./packages/dev/neovim.sh         # Text editor
./packages/dev/docker.sh         # Container runtime
./packages/desktop/brave.sh      # Browser
./packages/fonts/jetbrains-mono-nerd.sh  # Font
```

## Directory Structure

```
~/dotfiles/install/
├── lib/                          # Core libraries
│   ├── distro.sh                 # Detects OS distribution
│   ├── package-manager.sh        # Unified package manager interface
│   └── log.sh                    # Logging utilities
│
├── packages/                     # Individual package installers (116+)
│   ├── core/                     # Command-line utilities (60+)
│   ├── dev/                      # Development tools (35+)
│   ├── desktop/                  # GUI applications (18+)
│   ├── fonts/                    # Font families (5+)
│   └── special/                  # Complex installations (18+)
│
├── orchestration/                # Installation orchestration scripts
│   ├── install-all.sh            # Master installer (all packages)
│   ├── pre-reboot.sh             # System-level phase
│   └── post-reboot.sh            # User-level phase
│
├── nix/                          # NixOS integration
│   └── generate-packages.sh      # Auto-generate NixOS config
│
└── README.md                     # Technical documentation
```

## Package Categories

### Core (60+ packages)
Essential command-line utilities and system tools.

**Examples:**
- `bat` - Better cat with syntax highlighting
- `eza` - Better ls with icons and colors
- `fd` - Better find
- `ripgrep` - Better grep
- `zoxide` - Smarter cd
- `fzf` - Fuzzy finder
- `htop`, `btop` - System monitors
- `tldr` - Command examples
- `jq`, `yq` - JSON/YAML processors
- `age`, `gpg` - Encryption tools

### Dev (35+ packages)
Programming languages, build tools, version managers, and development utilities.

**Examples:**
- `neovim` - Text editor
- `git`, `lazygit` - Version control
- `docker` - Container runtime
- `node`, `bun`, `deno` - JavaScript runtimes
- `python`, `rust`, `go` - Programming languages
- `mise` - Version manager
- `gh` - GitHub CLI
- `act` - Run GitHub Actions locally
- `postgresql`, `redis` - Databases

### Desktop (18+ packages)
GUI applications for daily use.

**Examples:**
- `brave` - Privacy-focused browser
- `spotify` - Music streaming
- `discord` - Communication
- `obsidian` - Note-taking
- `vlc` - Media player
- `flameshot` - Screenshot tool
- `thunderbird` - Email client
- `libreoffice` - Office suite

### Fonts (5+ packages)
Font families for terminal and desktop use.

**Examples:**
- `jetbrains-mono-nerd` - JetBrains Mono with Nerd Font icons
- `fira-code-nerd` - Fira Code with ligatures
- `hack-nerd` - Hack font
- `meslo-nerd` - Meslo font

### Special (18+ packages)
Complex installations requiring special handling.

**Examples:**
- `package-managers.sh` - Install all package managers (run first!)
- `basic-system.sh` - Essential development libraries
- `container-runtime.sh` - Docker or Podman
- `cuda.sh` - NVIDIA CUDA toolkit
- `jetbrains-toolbox.sh` - JetBrains IDE manager
- `gaming.sh` - Steam, Lutris, gaming tools
- `virtualization.sh` - QEMU, virt-manager, VirtualBox

## Package Manager Priority

The installation system automatically detects your distribution and uses the appropriate package manager with the following priorities:

### Arch Linux (Current System)
1. **pacman** - Official Arch repositories (highest priority)
2. **yay/paru** - AUR (Arch User Repository)
3. **Language managers** - npm, cargo, go, etc. (last resort)

**Philosophy:** Prefer native packages over language-specific installers for better system integration.

### Ubuntu/Debian
1. **APT** - Official Ubuntu repositories (highest priority)
2. **Snap** - Canonical's universal package format
3. **Flatpak** - Universal Linux packages
4. **Pacstall** - Community AUR-like repository
5. **Language managers** - npm, cargo, go, etc. (last resort)

### NixOS
- **Declarative configuration** recommended (add packages to `configuration.nix`)
- **Guidance mode** - Installers print what to add to `configuration.nix`
- **Generator** - Auto-generate package lists with `nix/generate-packages.sh`

## Common Use Cases

### Setting Up a New Machine
```bash
# 1. Clone dotfiles
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Install package managers first (IMPORTANT!)
./install/packages/special/package-managers.sh

# 3. Install everything
./install/orchestration/install-all.sh

# 4. Set up configuration files
./setup.sh
```

### Installing Development Environment Only
```bash
cd ~/dotfiles/install

# Core utilities
for pkg in packages/core/*.sh; do bash "$pkg"; done

# Development tools
for pkg in packages/dev/*.sh; do bash "$pkg"; done

# Programming fonts
./packages/fonts/jetbrains-mono-nerd.sh
```

### Installing Desktop Environment Only
```bash
cd ~/dotfiles/install

# Desktop applications
for pkg in packages/desktop/*.sh; do bash "$pkg"; done

# Fonts
for pkg in packages/fonts/*.sh; do bash "$pkg"; done
```

### Adding a Package That Failed
If a package failed during full installation, you can re-run just that package:

```bash
cd ~/dotfiles/install
./packages/dev/neovim.sh
```

### Updating Installed Packages
The installers check if packages are already installed and skip them. To force reinstall:

```bash
# Arch Linux - reinstall specific package
sudo pacman -S --needed neovim

# Ubuntu - reinstall specific package
sudo apt install --reinstall neovim
```

## Troubleshooting

### Package Installation Fails

**Check distribution detection:**
```bash
cd ~/dotfiles/install
source lib/distro.sh
echo $DISTRO
```

Should output: `arch`, `ubuntu`, or `nixos`

**Install package managers first:**
```bash
./packages/special/package-managers.sh
```

This installs yay (Arch), flatpak, snap, etc.

**Run installer with debug mode:**
```bash
bash -x ./packages/core/bat.sh
```

**Check logs:**
Most installers output to stdout/stderr. Redirect to file for analysis:
```bash
./orchestration/install-all.sh 2>&1 | tee install.log
```

### AUR Package Fails (Arch Linux)

**Check if yay is installed:**
```bash
which yay
```

**Install yay manually:**
```bash
./packages/special/package-managers.sh
```

**Build with more verbose output:**
```bash
yay -S --nocleanmenu --nodiffmenu --noconfirm --needed <package>
```

### Package Not Found

Some packages have different names on different distributions:

| Common Name | Arch | Ubuntu | Notes |
|------------|------|--------|-------|
| fd | fd | fd-find | Symlink fd-find to fd |
| bat | bat | batcat | Symlink batcat to bat |
| neovim | neovim (pacman) | neovim (pacstall) | Ubuntu uses PPA or pacstall for latest |

The installers handle these differences automatically.

### Permission Denied

**Make installer executable:**
```bash
chmod +x ./packages/core/bat.sh
```

**Or run with bash explicitly:**
```bash
bash ./packages/core/bat.sh
```

### Installer Hangs

Some installers require user interaction (password, confirmations):

**For pacman (Arch):**
Most installers use `--noconfirm` flag

**For AUR (yay):**
May require manual confirmation for first-time builds

**For Flatpak/Snap:**
May require authentication

**Solution:** Monitor the installation and respond to prompts

### System Reboot Required

Some packages require a reboot:
- Kernel modules (NVIDIA drivers, VirtualBox)
- Display managers
- System services

**After installing these, reboot:**
```bash
sudo reboot
```

## NixOS Users

### Generate NixOS Package List

```bash
cd ~/dotfiles/install
./nix/generate-packages.sh
```

This creates `nix/generated-packages.nix` with all packages.

### Use Generated Configuration

1. Copy to NixOS config:
```bash
sudo cp nix/generated-packages.nix /etc/nixos/
```

2. Import in `/etc/nixos/configuration.nix`:
```nix
imports = [
  ./hardware-configuration.nix
  ./generated-packages.nix
];
```

3. Rebuild:
```bash
sudo nixos-rebuild switch
```

### Manual NixOS Installation

If you prefer to add packages manually to `configuration.nix`:

1. Run installer in guidance mode:
```bash
./packages/core/bat.sh
```

2. Installer will print what to add to `configuration.nix`

3. Add to your NixOS configuration and rebuild

## Best Practices

### First-Time Setup
1. **Run package managers installer first** - Ensures yay, flatpak, snap, etc. are available
2. **Use phased installation** - Safer for fresh systems
3. **Install category by category** - Easier to debug issues
4. **Check logs** - Review what was installed and what failed

### Regular Maintenance
1. **System updates** - Run `sudo pacman -Syu` (Arch) or `sudo apt update && sudo apt upgrade` (Ubuntu) regularly
2. **AUR updates** - Run `yay -Syu` (Arch) for AUR packages
3. **Flatpak updates** - Run `flatpak update` if using Flatpak
4. **Dotfiles updates** - Pull latest changes: `cd ~/dotfiles && git pull`

### Adding Custom Packages

If you need to add a package not in the installers:

1. **Check if similar installer exists** - Use as template
2. **Create new installer in appropriate category** - Follow naming convention
3. **Make executable** - `chmod +x packages/category/package.sh`
4. **Test on your distribution** - Run installer and verify it works
5. **Document any special requirements** - Add comments in the script

See `~/dotfiles/docs/ADDING-PACKAGES.md` for detailed instructions.

## Related Files

- **Main dotfiles setup:** `~/dotfiles/setup.sh`
- **Install system README:** `~/dotfiles/install/README.md`
- **Adding packages guide:** `~/dotfiles/docs/ADDING-PACKAGES.md` (if exists)
- **Distribution detection:** `~/dotfiles/install/lib/distro.sh`
- **Package manager abstraction:** `~/dotfiles/install/lib/package-manager.sh`

## Security Considerations

### Package Sources
- **pacman** - Official Arch repositories (signed packages)
- **AUR** - Community-maintained (review PKGBUILD before installing)
- **Flatpak/Snap** - Sandboxed applications
- **Language managers** - npm, cargo, go (verify package authenticity)

### Installation Safety
- Installers use `--needed` flag to avoid reinstalling
- Most use `--noconfirm` for automation (review scripts first!)
- AUR packages are built from source (inspect PKGBUILD)
- System packages require sudo (installers will prompt)

### Recommendations
- Review installer scripts before running
- Use phased installation for critical systems
- Keep backups before major installations
- Test on a VM first if unsure

## Getting Help

### Check Documentation
- This file: Package installation guide
- `~/dotfiles/install/README.md` - Technical details
- `~/dotfiles/README.md` - Overall dotfiles guide

### Debug Steps
1. Check distribution detection
2. Verify package managers are installed
3. Run single package installer with debug flag
4. Check system logs
5. Search Arch Wiki or Ubuntu documentation

### Common Issues
- **Package not found** - Different name on your distro
- **Permission denied** - Need sudo or make script executable
- **Build failed** - Missing dependencies (install build tools)
- **Network error** - Check internet connection and mirrors
