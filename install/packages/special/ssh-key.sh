#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/log.sh"           # provides `log`
source "$SCRIPT_DIR/../utils/copy-to-clip-board.sh"  # provides `copy_to_clipboard`

log "Setting up SSH key for GitHub..."

SSH_KEY_EXISTS=false
SSH_GITHUB_CONFIGURED=false
DEFAULT_KEY_PATH="$HOME/.ssh/id_ed25519"
skip_generation=false

# Check for existing SSH keys
if [[ -f "$DEFAULT_KEY_PATH.pub" ]]; then
    SSH_KEY_EXISTS=true
    log "Found existing SSH key: $DEFAULT_KEY_PATH.pub"
fi

# Check if SSH key is already configured with GitHub
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    SSH_GITHUB_CONFIGURED=true
    log "SSH key is already configured and working with GitHub"
    if [[ -f "$DEFAULT_KEY_PATH.pub" ]]; then
        log "Current key fingerprint:"
        ssh-keygen -lf "$DEFAULT_KEY_PATH.pub" 2>/dev/null || log "Could not read key fingerprint"
    fi
    read -p "SSH is already working with GitHub. Reconfigure anyway? (y/N): " reconfigure
    if [[ ! "$reconfigure" =~ ^[Yy]$ ]]; then
        log "Skipping SSH configuration - already working"
        exit 0
    fi
fi

# Use existing key if present but not configured
if [[ "$SSH_KEY_EXISTS" = true && "$SSH_GITHUB_CONFIGURED" = false ]]; then
    read -p "Use existing key at $DEFAULT_KEY_PATH.pub? (Y/n): " use_existing
    if [[ ! "$use_existing" =~ ^[Nn]$ ]]; then
        public_key=$(cat "$DEFAULT_KEY_PATH.pub")
        log "Using existing SSH key"
        if ! ssh-add -l 2>/dev/null | grep -q "$DEFAULT_KEY_PATH"; then
            log "Adding existing key to SSH agent..."
            eval "$(ssh-agent -s)" >/dev/null 2>&1 || true
            ssh-add "$DEFAULT_KEY_PATH" 2>/dev/null || log "Note: Key not added to agent (may require passphrase)"
        fi
        skip_generation=true
    fi
fi

# Generate new SSH key or use existing if not skipped
if [[ "$skip_generation" != true ]]; then
    read -p "Do you want to generate a new SSH key or use an existing one? (n)ew or (e)xisting [n]: " choice
    choice=${choice:-n}
    case "$choice" in
      e|E)
        read -p "Enter path to your existing SSH public key: " existing_key_path
        existing_key_path="${existing_key_path/#\~/$HOME}"
        if [ ! -f "$existing_key_path" ]; then
            log "Error: File not found: $existing_key_path"
            exit 1
        fi
        if ! ssh-keygen -lf "$existing_key_path" >/dev/null 2>&1; then
            log "Error: Invalid SSH public key format: $existing_key_path"
            exit 1
        fi
        public_key=$(cat "$existing_key_path")
        private_key_path="${existing_key_path%.pub}"
        if [[ -f "$private_key_path" ]] && ! ssh-add -l 2>/dev/null | grep -q "$private_key_path"; then
            log "Adding key to SSH agent..."
            eval "$(ssh-agent -s)" >/dev/null 2>&1 || true
            ssh-add "$private_key_path" 2>/dev/null || log "Note: Key not added to agent (may require passphrase)"
        fi
        ;;
      *)
        read -p "Enter your email address: " email
        if [[ ! "$email" =~ ^[^@]+@[^@]+\.[^@]+$ ]]; then
            log "Error: Invalid email format"
            exit 1
        fi
        key_path="$DEFAULT_KEY_PATH"
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        if [ -f "$key_path" ]; then
            read -p "SSH key exists at $key_path. Overwrite? (y/N) [N]: " overwrite
            overwrite=${overwrite:-n}
            if [[ "$overwrite" =~ ^[yY]$ ]]; then
                backup_path="${key_path}.backup.$(date +%s)"
                log "Backing up existing key to $backup_path"
                cp "$key_path" "$backup_path" 2>/dev/null || true
                cp "${key_path}.pub" "${backup_path}.pub" 2>/dev/null || true
                ssh-keygen -t ed25519 -C "$email" -f "$key_path"
            else
                log "Using existing key instead of generating new one"
            fi
        else
            ssh-keygen -t ed25519 -C "$email" -f "$key_path"
        fi
        public_key=$(cat "${key_path}.pub")
        log "Adding key to SSH agent..."
        eval "$(ssh-agent -s)" >/dev/null 2>&1 || true
        ssh-add "$key_path" 2>/dev/null || log "Note: Key not added to agent (may require passphrase)"
        ;;
    esac
fi

# Validate and show public key
if [ -z "$public_key" ]; then
    log "Error: Could not read public key"
    exit 1
fi
if ! echo "$public_key" | ssh-keygen -lf - >/dev/null 2>&1; then
    log "Error: Invalid public key format"
    exit 1
fi

log "Your public SSH key:"
copy_to_clipboard "$public_key"  # <--- Use the function here

# Instructions for GitHub
log "Next steps to configure the key on GitHub:"
echo "1. Go to GitHub Settings: https://github.com/settings/keys"
echo "2. Click 'New SSH key'"
echo "3. Paste the key above"
echo "4. Give it a descriptive title"

read -p "Press Enter after adding the key to GitHub..."

# Test SSH connection
log "Testing SSH connection to GitHub..."
set +e
ssh_test_output=$(ssh -T git@github.com -o ConnectTimeout=10 -o BatchMode=yes 2>&1)
set -e

if echo "$ssh_test_output" | grep -q "successfully authenticated"; then
    username=$(echo "$ssh_test_output" | grep "successfully authenticated" | sed 's/.*Hi \([^!]*\)!.*/\1/')
    log "SSH key successfully configured for GitHub user: $username"
else
    log "SSH connection failed or inconclusive:"
    log "$ssh_test_output"
    log "You can test manually with: ssh -T git@github.com"
fi

# Git config setup
if ! git config --global user.email >/dev/null 2>&1; then
    read -p "Git user email not configured. Set it up now? (Y/n): " setup_git
    if [[ ! "$setup_git" =~ ^[Nn]$ ]]; then
        if [[ -n "${email:-}" ]]; then
            git config --global user.email "$email"
            log "Set git user.email to: $email"
        else
            read -p "Enter your email for git commits: " git_email
            git config --global user.email "$git_email"
        fi
        read -p "Enter your name for git commits: " git_name
        git config --global user.name "$git_name"
        log "Git configuration updated"
    fi
fi
