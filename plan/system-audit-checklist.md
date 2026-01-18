# System Audit Checklist

**Purpose**: Verify that all dotfiles, modern tools, and customizations are properly installed and working.
**Last Updated**: 2026-01-17

---

## Quick Health Check

Run these commands to verify system health:

```bash
# Check all modern tools are installed
command -v eza bat fd dust btop procs rg fzf zoxide starship nvim mise yazi gh

# Verify dotfiles symlinks are healthy
find ~ -maxdepth 1 -type l -xtype l 2>/dev/null
find ~/.config -maxdepth 1 -type l -xtype l 2>/dev/null
find ~/.local/bin -maxdepth 1 -type l -xtype l 2>/dev/null

# Check custom brightness script
which omarchy-cmd-brightness
ls -l ~/.local/bin/omarchy-cmd-brightness

# Verify bash configuration loaded
type zi
alias | grep -E "(ls|la|ll)"
```

---

## 1. Modern CLI Tools Verification

### Essential Tools (All Should Be Installed)

- [ ] **eza** - Modern ls replacement
  ```bash
  eza --version  # Should show version
  ls            # Should be aliased to eza
  ```

- [ ] **bat** - Cat with syntax highlighting
  ```bash
  bat --version
  bat ~/.bashrc  # Should show colorized output
  ```

- [ ] **fd** - Fast file finder
  ```bash
  fd --version
  fd bashrc ~   # Should find .bashrc quickly
  ```

- [ ] **dust** - Better du (disk usage)
  ```bash
  dust --version
  dust -d 1 ~   # Show disk usage for home directory
  ```

- [ ] **btop** - Better top/htop
  ```bash
  btop --version
  # Launch with: btop (press 'q' to quit)
  ```

- [ ] **procs** - Better ps
  ```bash
  procs --version
  procs bash    # Should show bash processes
  ```

- [ ] **ripgrep (rg)** - Fast grep
  ```bash
  rg --version
  rg "alias" ~/.bashrc  # Should find aliases
  ```

- [ ] **fzf** - Fuzzy finder
  ```bash
  fzf --version
  # Test: Press Ctrl+T (should show file picker)
  # Test: Press Ctrl+R (should show history search)
  ```

- [ ] **zoxide** - Smart directory jumping
  ```bash
  zoxide --version
  z --help      # Should show zoxide help
  zi            # Should show interactive picker (if you have history)
  ```

- [ ] **starship** - Modern prompt
  ```bash
  starship --version
  echo $PROMPT_COMMAND  # Should include starship
  # Your prompt should show git info, directory, etc.
  ```

- [ ] **nvim** - Modern vim
  ```bash
  nvim --version | head -1  # Should show Neovim version
  ```

- [ ] **mise** - Universal version manager
  ```bash
  mise --version
  mise list     # Show installed tools
  ```

- [ ] **yazi** - Terminal file manager
  ```bash
  yazi --version
  type y        # Should show y() function for directory change
  ```

- [ ] **gh** - GitHub CLI
  ```bash
  gh --version
  gh auth status  # Check if authenticated
  ```

### Optional Tools (Nice to Have)

- [ ] **pyenv** - Python version manager
  ```bash
  test -d ~/.pyenv && echo "✓ Installed" || echo "✗ Not installed (using mise instead)"
  ```

---

## 2. Dotfiles Symlinks Verification

### Home Directory Files

- [ ] **~/.bashrc** → `~/dotfiles/home/.bashrc`
  ```bash
  ls -l ~/.bashrc
  grep "MINIMAL YET POWERFUL" ~/.bashrc  # Should show header
  ```

- [ ] **~/.bash_logout** → `~/dotfiles/home/.bash_logout`
  ```bash
  ls -l ~/.bash_logout
  ```

- [ ] **~/.profile** → `~/dotfiles/home/.profile`
  ```bash
  ls -l ~/.profile
  ```

- [ ] **~/.vimrc** → `~/dotfiles/home/.vimrc`
  ```bash
  ls -l ~/.vimrc
  ```

- [ ] **~/.gitconfig** → `~/dotfiles/home/.gitconfig`
  ```bash
  ls -l ~/.gitconfig
  git config --get user.name  # Should show your name
  ```

### Config Directories

- [ ] **~/.config/hypr/** → `~/dotfiles/home/.config/hypr/`
  ```bash
  ls -l ~/.config/hypr
  ls -l ~/.config/hypr/bindings.conf  # Should be a symlink
  ```

- [ ] **~/.config/nvim/** → `~/dotfiles/home/.config/nvim/`
  ```bash
  ls -l ~/.config/nvim
  ```

- [ ] **~/.config/omarchy/** → `~/dotfiles/home/.config/omarchy/`
  ```bash
  ls -l ~/.config/omarchy
  ls -d ~/.config/omarchy/themes/catppuccin-dark  # Custom theme
  ls -d ~/.config/omarchy/themes/mars            # Custom theme
  ```

- [ ] **~/.config/starship.toml** → `~/dotfiles/home/.config/starship.toml`
  ```bash
  ls -l ~/.config/starship.toml
  ```

### Local Bin Scripts

- [ ] **~/.local/bin/omarchy-cmd-brightness** → `~/dotfiles/home/.local/bin/omarchy-cmd-brightness`
  ```bash
  ls -l ~/.local/bin/omarchy-cmd-brightness
  file ~/.local/bin/omarchy-cmd-brightness  # Should show it's a symlink
  which omarchy-cmd-brightness              # Should show ~/.local/bin/ version
  ```

- [ ] **Other custom scripts** are symlinked
  ```bash
  ls -l ~/.local/bin/2fa
  ls -l ~/.local/bin/audit
  ls -l ~/.local/bin/sync-*
  ```

### Check for Broken Symlinks

- [ ] **No broken symlinks in home directory**
  ```bash
  find ~ -maxdepth 1 -type l -xtype l 2>/dev/null | wc -l  # Should be 0
  ```

- [ ] **No broken symlinks in ~/.config**
  ```bash
  find ~/.config -maxdepth 2 -type l -xtype l 2>/dev/null | wc -l  # Should be 0
  ```

- [ ] **No broken symlinks in ~/.local/bin**
  ```bash
  find ~/.local/bin -type l -xtype l 2>/dev/null | wc -l  # Should be 0
  ```

---

## 3. Omarchy Customizations Verification

### Brightness Control (Custom Implementation)

- [ ] **Custom brightness script is in PATH**
  ```bash
  which omarchy-cmd-brightness  # Should be ~/.local/bin/omarchy-cmd-brightness
  ```

- [ ] **Custom brightness bindings are active**
  ```bash
  grep -A5 "Custom media bindings" ~/.config/hypr/bindings.conf
  ```

- [ ] **Brightness keys work correctly**
  - Press brightness up key → should increase by 5%
  - Press brightness down key → should decrease by 5%
  - Brightness should never go below 1%
  - Press Alt+brightness keys → should change by 1%

### Custom Themes

- [ ] **catppuccin-dark theme available**
  ```bash
  test -d ~/.config/omarchy/themes/catppuccin-dark && echo "✓ Found" || echo "✗ Missing"
  omarchy-theme-set catppuccin-dark  # Test switching to theme
  ```

- [ ] **mars theme available**
  ```bash
  test -d ~/.config/omarchy/themes/mars && echo "✓ Found" || echo "✗ Missing"
  omarchy-theme-set mars  # Test switching to theme
  ```

### Custom Branding

- [ ] **Custom about.txt**
  ```bash
  cat ~/.config/omarchy/branding/about.txt  # Should show custom N logo
  ```

- [ ] **Custom screensaver.txt**
  ```bash
  cat ~/.config/omarchy/branding/screensaver.txt  # Should show custom text
  ```

### Verify Update-Proof Architecture

- [ ] **Brightness script won't be affected by omarchy updates**
  ```bash
  # Your script is in ~/.local/bin/ (user-managed)
  # NOT in ~/.local/share/omarchy/ (omarchy-managed)
  test -f ~/.local/share/omarchy/bin/omarchy-cmd-brightness && echo "✗ WRONG LOCATION" || echo "✓ Correct (not in omarchy repo)"
  ```

- [ ] **Bindings won't be affected by omarchy updates**
  ```bash
  # Your bindings are in ~/.config/hypr/bindings.conf (user config)
  # NOT in ~/.local/share/omarchy/ (omarchy defaults)
  grep -c "Custom media bindings" ~/.config/hypr/bindings.conf  # Should be > 0
  ```

---

## 4. Bash Configuration Verification

### Core Features

- [ ] **Minimal yet powerful configuration loaded**
  ```bash
  grep -c "MINIMAL YET POWERFUL" ~/.bashrc  # Should be 1
  ```

- [ ] **Starship prompt active**
  ```bash
  echo $PROMPT_COMMAND | grep -q starship && echo "✓ Active" || echo "✗ Not active"
  # Your prompt should show git branch, directory, etc.
  ```

- [ ] **Zoxide initialized**
  ```bash
  type z | grep -q function && echo "✓ Active" || echo "✗ Not active"
  ```

- [ ] **Zoxide interactive picker (zi) function exists**
  ```bash
  type zi | grep -q function && echo "✓ Active" || echo "✗ Not active"
  ```

- [ ] **fzf keybindings active**
  - Ctrl+T should open file picker
  - Ctrl+R should open history search
  - Alt+C should open directory picker

- [ ] **Command timing active**
  ```bash
  sleep 2  # Should show "⏱  2s" after completion
  ```

- [ ] **Enhanced history configured**
  ```bash
  echo $HISTSIZE      # Should be 50000
  echo $HISTFILESIZE  # Should be 100000
  ```

### Aliases

- [ ] **ls → eza (tasteful)**
  ```bash
  alias ls  # Should show: alias ls='eza'
  ls        # Should show eza output
  ```

- [ ] **ll alias exists**
  ```bash
  alias ll  # Should show: alias ll='eza -l'
  ```

- [ ] **la alias exists**
  ```bash
  alias la  # Should show: alias la='eza -la'
  ```

- [ ] **code → codium (if code doesn't exist)**
  ```bash
  command -v code &>/dev/null && echo "code exists (codium not aliased)" || alias code
  ```

- [ ] **Directory navigation shortcuts**
  ```bash
  alias ..    # Should show: alias ..='cd ..'
  alias ...   # Should show: alias ...='cd ../..'
  alias ....  # Should show: alias ....='cd ../../..'
  alias -- -  # Should show: alias -- -='cd -'
  ```

### Functions

- [ ] **dotfiles() function exists**
  ```bash
  type dotfiles | grep -q function && echo "✓ Active" || echo "✗ Not active"
  ```

- [ ] **y() function for yazi exists**
  ```bash
  type y | grep -q function && echo "✓ Active" || echo "✗ Not active"
  ```

- [ ] **mkcd() function exists**
  ```bash
  type mkcd | grep -q function && echo "✓ Active" || echo "✓ Active" || echo "✗ Not active"
  ```

- [ ] **extract() function exists**
  ```bash
  type extract | grep -q function && echo "✓ Active" || echo "✗ Not active"
  ```

### Tool Initialization

- [ ] **mise initialized (if installed)**
  ```bash
  command -v mise &>/dev/null && mise list || echo "mise not installed"
  ```

- [ ] **SSH agent configured**
  ```bash
  echo $SSH_AUTH_SOCK  # Should show socket path
  ssh-add -l &>/dev/null && echo "✓ Keys loaded" || echo "No keys or agent not running"
  ```

- [ ] **direnv initialized (if installed)**
  ```bash
  command -v direnv &>/dev/null && type _direnv_hook || echo "direnv not installed"
  ```

---

## 5. System Configuration Verification

### DNS Configuration

- [ ] **dnsmasq is running**
  ```bash
  systemctl status dnsmasq | grep -q "active (running)" && echo "✓ Running" || echo "✗ Not running"
  ```

- [ ] **DNS resolution works**
  ```bash
  ping -c 1 google.com &>/dev/null && echo "✓ DNS working" || echo "✗ DNS broken"
  ```

### User Services

- [ ] **Battery notification timer active**
  ```bash
  systemctl --user is-active battery-notify.timer
  ```

- [ ] **NAS sync timers (if enabled)**
  ```bash
  systemctl --user list-timers | grep nas-sync || echo "NAS sync not enabled"
  ```

### System Files Deployed

- [ ] **Power profile udev rule installed**
  ```bash
  test -f /etc/udev/rules.d/99-power-profile.rules && echo "✓ Installed" || echo "✗ Not installed"
  ```

- [ ] **Package management config deployed (if done)**
  ```bash
  test -f /etc/pacman.conf && grep -q "Color" /etc/pacman.conf && echo "✓ Custom pacman.conf" || echo "Stock pacman.conf"
  ```

---

## 6. Post-Installation Checks

### After Running setup.sh

- [ ] **No errors during deployment**
  ```bash
  cd ~/dotfiles && ./setup.sh --dry-run  # Should complete without errors
  ```

- [ ] **Symlinks are idempotent**
  ```bash
  # Run setup.sh twice, second run should skip existing symlinks
  cd ~/dotfiles && ./setup.sh --dry-run
  cd ~/dotfiles && ./setup.sh --dry-run  # Should show same output
  ```

- [ ] **Permissions correct for sensitive files**
  ```bash
  stat -c "%a" ~/.ssh/config         # Should be 600
  stat -c "%a" ~/.ssh                # Should be 700
  stat -c "%a" ~/.gnupg              # Should be 700
  ```

### After Omarchy Update

- [ ] **Custom brightness script still works**
  ```bash
  which omarchy-cmd-brightness  # Should still be ~/.local/bin/ version
  omarchy-cmd-brightness +5     # Should change brightness
  ```

- [ ] **Custom themes still available**
  ```bash
  omarchy-theme-set catppuccin-dark  # Should work
  omarchy-theme-set mars             # Should work
  ```

- [ ] **Custom bindings still active**
  ```bash
  grep -c "Custom media bindings" ~/.config/hypr/bindings.conf  # Should be > 0
  ```

---

## 7. Documentation Verification

### Required Documentation Files

- [ ] **~/dotfiles/docs/modern-cli-tools.md** exists
  ```bash
  test -f ~/dotfiles/docs/modern-cli-tools.md && echo "✓ Found" || echo "✗ Missing"
  ```

- [ ] **~/dotfiles/docs/bash-configuration.md** exists
  ```bash
  test -f ~/dotfiles/docs/bash-configuration.md && echo "✓ Found" || echo "✗ Missing"
  ```

- [ ] **~/dotfiles/docs/brightness-control.md** exists and updated
  ```bash
  test -f ~/dotfiles/docs/brightness-control.md && echo "✓ Found" || echo "✗ Missing"
  grep -q "~/.local/bin/omarchy-cmd-brightness" ~/dotfiles/docs/brightness-control.md && echo "✓ Paths updated" || echo "✗ Old paths"
  ```

- [ ] **~/dotfiles/README.md** is up to date
  ```bash
  test -f ~/dotfiles/README.md && echo "✓ Found" || echo "✗ Missing"
  ```

---

## 8. Known Good State

If all checks pass, your system is in a known good state:

✅ All modern CLI tools installed and working
✅ All dotfiles symlinks healthy (no broken links)
✅ Omarchy customizations in place and update-proof
✅ Bash configuration loaded with fish-like features
✅ System services running correctly
✅ Documentation up to date

---

## Troubleshooting

### If symlinks are broken

```bash
cd ~/dotfiles
./setup.sh --backup  # Creates .bak files before fixing symlinks
```

### If bash features not working

```bash
source ~/.bashrc  # Reload configuration
```

### If brightness control not working

```bash
# Check if script is executable
chmod +x ~/dotfiles/home/.local/bin/omarchy-cmd-brightness

# Check if it's in PATH
which omarchy-cmd-brightness  # Should be ~/.local/bin/omarchy-cmd-brightness

# Check bindings
grep "XF86MonBrightness" ~/.config/hypr/bindings.conf

# Reload Hyprland config
hyprctl reload
```

### If custom themes missing

```bash
# Check if themes are symlinked
ls -l ~/.config/omarchy/themes/

# If missing, run setup.sh
cd ~/dotfiles && ./setup.sh --backup
```

---

## Automated Audit Script

Create `~/dotfiles/audit.sh` for automated checking:

```bash
#!/bin/bash
# Quick system audit script

echo "=== Modern Tools Check ==="
for tool in eza bat fd dust btop procs rg fzf zoxide starship nvim mise yazi gh; do
  if command -v $tool &>/dev/null; then
    echo "✓ $tool"
  else
    echo "✗ $tool (missing)"
  fi
done

echo ""
echo "=== Broken Symlinks Check ==="
broken=$(find ~ -maxdepth 1 -type l -xtype l 2>/dev/null | wc -l)
echo "Home directory: $broken broken symlink(s)"
broken=$(find ~/.config -maxdepth 2 -type l -xtype l 2>/dev/null | wc -l)
echo "Config directory: $broken broken symlink(s)"
broken=$(find ~/.local/bin -type l -xtype l 2>/dev/null | wc -l)
echo "Local bin: $broken broken symlink(s)"

echo ""
echo "=== Omarchy Customizations Check ==="
if [ -L ~/.local/bin/omarchy-cmd-brightness ]; then
  echo "✓ Brightness script symlinked"
else
  echo "✗ Brightness script missing"
fi

if grep -q "Custom media bindings" ~/.config/hypr/bindings.conf 2>/dev/null; then
  echo "✓ Custom brightness bindings active"
else
  echo "✗ Custom brightness bindings missing"
fi

if [ -d ~/.config/omarchy/themes/catppuccin-dark ]; then
  echo "✓ catppuccin-dark theme present"
else
  echo "✗ catppuccin-dark theme missing"
fi

if [ -d ~/.config/omarchy/themes/mars ]; then
  echo "✓ mars theme present"
else
  echo "✗ mars theme missing"
fi

echo ""
echo "=== Bash Configuration Check ==="
if type zi | grep -q function; then
  echo "✓ zi function loaded"
else
  echo "✗ zi function missing"
fi

if alias ls | grep -q eza; then
  echo "✓ ls aliased to eza"
else
  echo "✗ ls not aliased to eza"
fi

echo ""
echo "=== All checks complete ==="
```

---

**Next Steps:**
1. Run through each section of this checklist
2. Fix any issues found
3. Mark items as complete with `[x]`
4. Keep this checklist for future reference after system updates
