# Bash Configuration

## Philosophy

- **Modern tools available** with clean shortcuts
- **Standard commands preserved** (ls, cat, vim, top, ps, find, df)
- **Smart aliasing**: Only mask if standard command doesn't exist
- **Simple & elegant**: Standardized naming, well-organized sections

## What Gets Aliased

Based on your system:

### Aliased (standard command doesn't exist)
- `vi` → `nvim` (vi doesn't exist on your system)
- `htop` → `btop` (htop doesn't exist on your system)
- `code` → `codium` (code doesn't exist, if codium is installed)

### NOT Aliased (standard commands exist)
- `ls`, `cat`, `vim`, `find`, `top`, `ps`, `df` - all preserved

## Quick Reference

### Listing
```bash
l          # eza (with icons)
ll         # eza -lah (long format)
la         # eza -a (show hidden)
lt         # eza --tree (tree view)
ls         # standard ls (unchanged)
```

### Navigation
```bash
z <dir>    # Smart jump to frequently used directory
zi         # Interactive directory picker (auto cd)
..         # cd ..
...        # cd ../..
....       # cd ../../..
-          # cd - (previous directory)
up 3       # Go up 3 directories
```

### Editor
```bash
v          # nvim
vi         # nvim (aliased)
vim        # vim (standard)
```

### Git Shortcuts
```bash
g          # git
gs         # git status
ga         # git add
gaa        # git add --all
gc         # git commit
gcm        # git commit -m
gp         # git push
gpl        # git pull
gd         # git diff
gds        # git diff --staged
gco        # git checkout
gcb        # git checkout -b
gb         # git branch
gba        # git branch -a
glog       # git log --oneline --graph --decorate
gst        # git stash
gstp       # git stash pop
```

### Modern Utilities
```bash
bat        # Cat with syntax highlighting
fd         # Fast file finder
btop       # System monitor
htop       # → btop (aliased)
procs      # Process viewer
dust       # Disk usage analyzer
```

### Clipboard (Wayland)
```bash
pbcopy     # wl-copy
pbpaste    # wl-paste
```

### Fuzzy Finder (fzf)
- `Ctrl+T` - Find files
- `Ctrl+R` - Search history
- `Alt+C` - Change directory

## Features

- ✓ **Starship prompt** - Modern, git-aware, informative
- ✓ **Command timing** - Shows execution time for slow commands (>1s)
- ✓ **Enhanced history** - 50k entries with smart search
- ✓ **Auto-cd** - Type directory name to cd into it (e.g., just type `/tmp`)
- ✓ **Smart suggestions** - Unknown commands suggest packages to install
- ✓ **Zoxide** - Smart directory jumping based on frecency

## Apply Changes

```bash
source ~/.bashrc
```

## Structure

The `.bashrc` is organized into clear sections:

1. **History Configuration** - Fish-like infinite history
2. **Shell Options** - Auto-cd, spell correction, etc.
3. **PATH Configuration** - Smart PATH management
4. **Modern Tools** - Smart aliasing for modern replacements
5. **Editor Shortcuts** - nvim shortcuts
6. **Directory Navigation** - .., ..., up N, etc.
7. **Git Shortcuts** - Convenient git aliases
8. **Clipboard** - Wayland clipboard integration
9. **Command Not Found** - Helpful suggestions
10. **Tool Initialization** - pyenv, fnm, zoxide, fzf, etc.

## Optional Software

All essential tools are already installed. Optional additions:

- `duf` - Prettier df alternative
  ```bash
  sudo pacman -S duf
  ```

- `ble.sh` - Fish-like syntax highlighting and autosuggestions
  ```bash
  git clone --recursive --depth 1 --shallow-submodules \
    https://github.com/akinomyoga/ble.sh.git ~/.local/share/blesh
  make -C ~/.local/share/blesh install PREFIX=~/.local
  ```

## Testing

All aliases have been tested and verified working on your system.
