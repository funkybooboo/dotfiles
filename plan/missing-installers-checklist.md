# Missing Package Installers Checklist

**Total Packages:** 145
**Date Created:** 2026-01-06
**Last Updated:** 2026-01-12
**Status:** In Progress

## Overview
This document tracks all installed packages that don't have installers yet in `~/dotfiles/install/packages/`. Mark items as complete as installers are created.

## High Priority Packages (15)

### Core Utilities
- [x] `nmap` - Network scanner and security auditing tool
- [x] `gum` - Shell script beautification and TUI components
- [x] `pacman-contrib` - Pacman utilities (paccache, checkupdates, pacdiff, etc.)
- [x] `sshpass` - Non-interactive SSH password authentication
- [x] `openbsd-netcat` - OpenBSD netcat implementation
- [x] `xmlstarlet` - Command-line XML toolkit

### Development
- [x] `asciinema-git` - Terminal session recorder
- [x] `tree-sitter-cli` - Parser generator tool for syntax highlighting
- [ ] `valgrind` - Memory debugging and profiling tool
- [ ] `sysbench` - Scriptable database and system performance benchmark
- [ ] `gemini-cli` - Google Gemini AI CLI client

### C/C++ Development Tools
#### Core Toolchain (Already Installed)
- [x] `llvm` - LLVM compiler infrastructure
- [x] `clang` - C/C++ compiler front-end
- [x] `gcc` - GNU Compiler Collection (g++)
- [x] `cmake` - Cross-platform build system
- [x] `make` - GNU Make build tool
- [x] `binutils` - objdump, hexdump, readelf, nm, strings, addr2line, objcopy, ldd

#### Debuggers & Profiling
- [ ] `gdb` - GNU Debugger
- [ ] `lldb` - LLVM debugger
- [ ] `python-gdbgui` (AUR) - Browser-based GDB frontend
- [ ] `strace` - System call tracer
- [ ] `ltrace` - Library call tracer
- [ ] `perf` - Linux performance profiling tool
- [ ] `heaptrack` - Heap memory profiler
- [ ] `kcachegrind` - Callgrind/cachegrind visualizer
- [ ] `massif-visualizer` - Valgrind massif heap profiler GUI

#### Build Systems & Tools
- [ ] `ninja` - Fast build system
- [ ] `meson` - Modern build system
- [ ] `ccache` - Compiler cache for faster rebuilds
- [ ] `sccache` - Shared compilation cache
- [ ] `bear` - Compilation database generator
- [ ] `autoconf` - GNU Autotools configuration
- [ ] `automake` - GNU Autotools makefile generator
- [ ] `libtool` - Generic library support script

#### Code Quality & Analysis
- [x] `clang-format` - Code formatter
- [x] `clang-tidy` - C++ linter
- [ ] `cppcheck` - Static analyzer for C/C++
- [ ] `lcov` - Code coverage visualization

#### Language Servers (LSP)
- [x] `clangd` - C/C++ Language Server (included in llvm/clang)
- [ ] `pyright` - Python Language Server (via npm/Mason)
- [ ] `typescript-language-server` - TypeScript/JavaScript LSP (via npm)
- [ ] `jdtls` - Java Language Server (via Mason)
- [ ] `lua-language-server` - Lua Language Server
- [ ] `rust-analyzer` - Rust Language Server

#### Editor/IDE Tools
- [ ] `mason.nvim` - Neovim LSP/DAP/Linter/Formatter installer (via Lazy.nvim)
- [ ] `lazy.nvim` - Modern Neovim plugin manager

#### Testing & Benchmarking
- [ ] `gtest` - Google Test framework
- [ ] `catch2` - Modern C++ test framework
- [ ] `boost` - C++ libraries (includes test framework)
- [ ] `benchmark` - Google's microbenchmarking library
- [ ] `hyperfine` - Command-line benchmarking tool

#### Assembly & Low-Level
- [x] `binutils` - Includes GAS (GNU Assembler, AT&T syntax)
- [x] `nasm` - Netwide Assembler (Intel syntax, most popular)
- [x] `yasm` - YASM assembler (NASM rewrite, Intel syntax)
- [x] `llvm` - Includes LLVM integrated assembler
- [ ] `fasm` - Flat Assembler (own syntax, very fast)
- [ ] `uasm` - MASM-compatible assembler for Linux
- [ ] `keystone` - Multi-platform, multi-architecture assembler framework
- [ ] `sasm` (AUR) - Simple IDE for NASM/GAS/FASM with debugger
- [ ] `asm-lsp` - Assembly Language Server Protocol (via cargo)
- [ ] `asmfmt` - Assembly code formatter

#### Binary Analysis & Reverse Engineering
- [ ] `rizin` - Reverse engineering framework
- [ ] `cutter` - GUI for rizin
- [ ] `radare2` - Alternative reverse engineering framework

#### Hex Editors
- [ ] `hexedit` - Terminal hex editor
- [ ] `imhex-bin` (AUR) - Modern GUI hex editor

#### Documentation & Utilities
- [ ] `doxygen` - Documentation generator
- [ ] `graphviz` - Graph visualization (for doxygen)
- [x] `pkg-config` - Library management utility
- [ ] `ctags` - Code indexing for editors
- [ ] `qt6-base` - Qt6 base (needed for cmake-gui)

#### Advanced Tools
- [ ] `cling` (AUR) - Interactive C++ interpreter (REPL)
- [ ] `distcc` - Distributed C/C++ compilation
- [ ] `compiler-rt` - Sanitizer runtime libraries
- [ ] `git-delta` - Syntax-highlighting git diff
- [ ] `meld` - Visual diff/merge tool
- [ ] `nemiver` - GTK-based debugger frontend

### Desktop Applications
- [ ] `localsend` - Cross-platform local file sharing (AirDrop alternative)
- [ ] `vscodium-bin` - VS Code without Microsoft telemetry
- [ ] `typora` - Markdown editor with live preview
- [ ] `pinta` - Simple image editor (Paint.NET alternative)
- [ ] `lazyssh` - tui for ssh

## Medium Priority Packages (25)

### Core Utilities
- [ ] `arch-wiki-docs` - Offline Arch Wiki documentation
- [ ] `arch-wiki-lite` - Lightweight offline Arch Wiki
- [ ] `hdparm` - Hard disk parameter utility
- [ ] `usage` - Tool for monitoring system resources
- [ ] `wmctrl` - Command-line window manager control

### Development
- [ ] `nodejs` - JavaScript runtime environment
- [ ] `npm` - Node.js package manager
- [ ] `tea` - Gitea command-line client
- [ ] `postgresql-libs` - PostgreSQL client libraries
- [ ] `mariadb-libs` - MariaDB client libraries
- [ ] `pmbootstrap` - PostmarketOS bootstrap tool
- [ ] `opencode` - Open source code search tool

### Desktop Applications
- [ ] `minecraft-launcher` - Official Minecraft launcher
- [ ] `rpi-imager` - Raspberry Pi Imager for writing OS images
- [ ] `nwg-displays` - Output management utility for Wayland compositors
- [ ] `system-config-printer` - Printer configuration GUI
- [ ] `glmark2` - OpenGL 2.0 and ES 2.0 benchmark
- [ ] `bluetui` - Bluetooth manager TUI

### Input Methods
- [ ] `fcitx5` - Input method framework
- [ ] `fcitx5-gtk` - Fcitx5 GTK IM Module
- [ ] `fcitx5-qt` - Fcitx5 Qt IM Module

### System Tools
- [ ] `kiwix-tools` - Offline Wikipedia/wiki reader tools
- [ ] `batmon` - Battery monitor for the command line
- [ ] `bolt` - Thunderbolt device manager
- [ ] `aether` - Peer-to-peer Reddit alternative
- [ ] `ufw-docker` - UFW rules for Docker containers
- [ ] `tzupdate` - Automatically update timezone based on location

## Low Priority / System-Specific (47)

### System Components
- [ ] `dkms` - Dynamic Kernel Module Support
- [ ] `intel-ucode` - Intel CPU microcode updates
- [ ] `iptables-nft` - iptables over nftables
- [ ] `inetutils` - Collection of common network programs
- [ ] `wireless-regdb` - Wireless regulatory database
- [ ] `sof-firmware` - Sound Open Firmware
- [ ] `systemd-resolvconf` - systemd resolvconf implementation
- [ ] `zram-generator` - systemd unit generator for zram devices

### CUPS/Printing
- [ ] `cups-browsed` - CUPS daemon for browsing remote printers
- [ ] `cups-filters` - CUPS filters and backends
- [ ] `cups-pdf` - PDF printer for CUPS

### Hyprland Ecosystem
- [ ] `hyprland-guiutils` - Hyprland GUI utilities
- [ ] `hyprland-preview-share-picker` - Screen sharing picker for Hyprland
- [ ] `wlctl-bin` - Wayland control utility
- [ ] `uwsm` - Universal Wayland Session Manager

### Boot/System Management
- [ ] `limine` - Modern multiprotocol bootloader
- [ ] `limine-mkinitcpio-hook` - mkinitcpio hook for Limine
- [ ] `limine-snapper-sync` - Snapper integration for Limine

### Omarchy Project (Custom Packages)
- [ ] `omarchy-chromium` - Omarchy Chromium build
- [ ] `omarchy-keyring` - Omarchy package signing keys
- [ ] `omarchy-nvim` - Omarchy Neovim configuration
- [ ] `omarchy-walker` - Omarchy Walker application

### Desktop Environment Components
- [ ] `kvantum-qt5` - SVG-based Qt5 theme engine
- [ ] `xdg-desktop-portal-gtk` - GTK implementation of xdg-desktop-portal
- [ ] `xdg-terminal-exec` - Reference implementation of XDG terminal execution
- [ ] `yaru-icon-theme` - Ubuntu Yaru icon theme

### Media/Audio
- [ ] `pipewire-alsa` - PipeWire ALSA configuration
- [ ] `pipewire-jack` - PipeWire JACK support
- [ ] `wireplumber` - Session/policy manager for PipeWire
- [ ] `wiremix` - Audio mixer for WirePlumber
- [ ] `ffmpegthumbnailer` - Lightweight video thumbnailer

### Proton Services
- [ ] `proton-pass-cli-bin` - Proton Pass command-line client
- [ ] `proton-pass-cli-bin-debug` - Debug symbols for Proton Pass CLI

### Network/VPN
- [ ] `globalprotect-openconnect-git` - GlobalProtect VPN client
- [ ] `nss-mdns` - NSS module for mDNS name resolution

### Fonts
- [ ] `fontconfig` - Font configuration and customization library
- [ ] `woff2-font-awesome` - Font Awesome in WOFF2 format

### TeX/LaTeX
- [ ] `texlive-basic` - Basic TeX Live packages
- [ ] `texlive-fontsextra` - TeX Live extra fonts
- [ ] `texlive-latexextra` - TeX Live LaTeX extra packages

### Virtualization
- [ ] `virtualbox` - Oracle VM VirtualBox
- [ ] `virtualbox-host-modules-arch` - VirtualBox kernel modules
- [ ] `virt-viewer` - Virtual machine viewer

### Experimental/Testing
- [ ] `act-git` - Run GitHub Actions locally (git version)
- [ ] `asdcontrol` - AMD GPU control utility
- [ ] `tobi-try` - Try packages without installing them
- [ ] `yay-debug` - Debug symbols for yay

### Documentation
- [ ] `man-pages` - Linux man pages

### Deprecated/Replaced
- [ ] `ksshaskpass` - ✅ Already documented in KWallet integration (not needed)

## Notes

### Packages to Skip
Some packages don't need installers:
- `yay-debug` - Debug symbols, only needed for debugging yay
- `proton-pass-cli-bin-debug` - Debug symbols
- `omarchy-*` - Custom project-specific packages
- `limine-*` - Bootloader-specific, already handled by system setup
- `intel-ucode` - CPU-specific, should be in base system installer
- `ksshaskpass` - Already documented in KWallet docs

### Installation Categories
When creating installers, place them in:
- `packages/core/` - CLI utilities and system tools
- `packages/dev/` - Development tools and languages
- `packages/desktop/` - GUI applications
- `packages/fonts/` - Font packages
- `packages/special/` - Complex installations requiring special handling

### Template
Use `~/dotfiles/install/packages/core/bat.sh` as template for simple packages.

For packages that need AUR (Arch) or special handling, see `~/dotfiles/install/packages/core/yay.sh`.

### Progress Tracking
- **Not Started:** 97 packages (updated 2026-01-12)
- **In Progress:** 0 packages
- **Completed:** 48 packages (marked with [x])
- **Skipped:** 0 packages

**Recent Additions (2026-01-12):**
- Language Server Protocol tools (pyright, typescript-language-server, jdtls, lua-language-server, rust-analyzer)
- Assembly tools (asm-lsp, asmfmt)
- Editor/IDE tools (mason.nvim, lazy.nvim)
- JavaScript runtime (nodejs, npm)

## Next Steps
1. Start with High Priority packages (15 items)
2. Move to Medium Priority (25 items)
3. Evaluate Low Priority packages individually
4. Skip system-specific and debug packages

## Related Documentation
- Installation system: `~/dotfiles/docs/package-installation.md`
- Technical README: `~/dotfiles/install/README.md`
- Existing installers: `~/dotfiles/install/packages/`
