# Modern CLI Tools Reference

This is a reference for modern command-line tools installed on your system. Use them by their real names.

## File & Directory Tools

### eza - Modern ls
```bash
eza              # List files (aliased to ls)
eza -l           # Long format (aliased to ll)
eza -la          # Long format with hidden files (aliased to la)
eza --tree       # Tree view
eza --git        # Show git status
```

### bat - Cat with syntax highlighting
```bash
bat file.txt     # View file with syntax highlighting
bat -p file.txt  # Plain output (no decorations)
bat --diff       # Show git diff
```

### fd - Fast file finder
```bash
fd pattern       # Find files matching pattern
fd -e txt        # Find files by extension
fd -H pattern    # Include hidden files
fd -t f          # Files only
fd -t d          # Directories only
```

### dust - Better du (disk usage)
```bash
dust             # Show disk usage for current directory
dust -d 2        # Depth 2
dust /path       # Specific path
```

## System Monitoring

### btop - Better top/htop
```bash
btop             # Interactive system monitor
```

### procs - Better ps
```bash
procs            # List all processes (better than ps aux)
procs firefox    # Find processes by name
procs --tree     # Tree view
```

## Search Tools

### ripgrep (rg) - Fast grep
```bash
rg pattern       # Search in current directory
rg -i pattern    # Case insensitive
rg -t py pattern # Search only .py files
rg --hidden      # Include hidden files
```

### fzf - Fuzzy finder
```bash
Ctrl+T           # Fuzzy file search
Ctrl+R           # Fuzzy history search
Alt+C            # Fuzzy directory change
```

## Navigation

### zoxide - Smart directory jumping
```bash
z partial        # Jump to directory (learns from history)
z -            # Jump to previous directory
zi               # Interactive directory picker (custom function)
zoxide query     # Show matching directories
```

## Editor

### nvim - Modern vim
```bash
nvim file.txt    # Edit file
nvim .           # Open current directory
nvim -d a b      # Diff mode
```

## Git (use full commands)
```bash
git status       # Check status
git add .        # Stage all changes
git commit -m    # Commit with message
git push         # Push to remote
git pull         # Pull from remote
git diff         # Show changes
git log          # View history
git branch       # List branches
git checkout     # Switch branches
```

## Version Managers

### mise - Universal version manager
```bash
mise install node@20    # Install Node.js 20
mise use node@20        # Use Node.js 20 in current directory
mise list               # List installed versions
```

### pyenv - Python version manager
```bash
pyenv install 3.12.0    # Install Python version
pyenv global 3.12.0     # Set global Python version
pyenv local 3.11.0      # Set local Python version
```

## Standard Tools (still available)
- `cat` - Simple file concatenation
- `find` - Standard find command
- `ls` - Standard list (now points to eza)
- `grep` - Standard grep
- `top` - Standard process viewer
- `ps` - Standard process list
- `du` - Standard disk usage
- `vim` - Classic vim editor

## Tips
1. Use modern tools by their real names to understand what you're running
2. Standard commands are still available when you need them
3. Check `--help` or `man` pages for each tool
4. Modern tools are generally faster and have better defaults
