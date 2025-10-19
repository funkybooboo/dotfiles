#!/usr/bin/env bash

set -e
set -o pipefail

echo "Setup SSH key for GitHub"
# Check if SSH key already exists and is configured
SSH_KEY_EXISTS=false
SSH_GITHUB_CONFIGURED=false
DEFAULT_KEY_PATH="$HOME/.ssh/id_ed25519"
# Check for existing SSH keys
if [[ -f "$DEFAULT_KEY_PATH.pub" ]]; then
    SSH_KEY_EXISTS=true
    echo "Found existing SSH key: $DEFAULT_KEY_PATH.pub"
fi
# Check if SSH key is already configured with GitHub
if ssh -T git@git.empdev.domo.com 2>&1 | grep -q "successfully authenticated"; then
    SSH_GITHUB_CONFIGURED=true
    echo "SSH key is already configured and working with GitHub"
    # Show current key info
    if [[ -f "$DEFAULT_KEY_PATH.pub" ]]; then
        echo "Current key fingerprint:"
        ssh-keygen -lf "$DEFAULT_KEY_PATH.pub" 2>/dev/null || echo "Could not read key fingerprint"
    fi
    read -p "SSH is already working with GitHub. Reconfigure anyway? (y/N): " reconfigure
    if [[ ! "$reconfigure" =~ ^[Yy]$ ]]; then
        echo "Skipping SSH configuration - already working"
        exit 0
    fi
fi
# If key exists but not configured with GitHub, offer to use it
if [[ "$SSH_KEY_EXISTS" = true && "$SSH_GITHUB_CONFIGURED" = false ]]; then
    echo "Found existing SSH key but it's not configured with GitHub (or test failed)"
    read -p "Use existing key at $DEFAULT_KEY_PATH.pub? (Y/n): " use_existing
    if [[ ! "$use_existing" =~ ^[Nn]$ ]]; then
        public_key=$(cat "$DEFAULT_KEY_PATH.pub")
        echo "Using existing SSH key"
        # Add key to SSH agent if not already added
        if ! ssh-add -l 2>/dev/null | grep -q "$DEFAULT_KEY_PATH"; then
            echo "Adding existing key to SSH agent..."
            eval "$(ssh-agent -s)" > /dev/null 2>&1 || true
            ssh-add "$DEFAULT_KEY_PATH" 2>/dev/null || echo "Note: Key not added to agent (may require passphrase)"
        fi
        skip_generation=true
    fi
fi
# Ask user if they want to generate a new SSH key or use an existing one
if [[ "$skip_generation" != true ]]; then
    echo "Do you want to generate a new SSH key or use an existing one?"
    read -p "(n)ew or (e)xisting [n]: " choice
    choice=${choice:-n}
    case "$choice" in
      e|E)
        # Ask user where their existing SSH public key is located
        echo "Please enter the path to your existing SSH public key:"
        read -p "> " existing_key_path
        # Expand tilde to home directory
        existing_key_path="${existing_key_path/#\~/$HOME}"
        if [ ! -f "$existing_key_path" ]; then
          echo "Error: File not found: $existing_key_path"
          exit 1
        fi
        # Validate it's actually a public key
        if ! ssh-keygen -lf "$existing_key_path" >/dev/null 2>&1; then
          echo "Error: Invalid SSH public key format: $existing_key_path"
          exit 1
        fi
        public_key=$(cat "$existing_key_path")
        # Try to add corresponding private key to SSH agent
        private_key_path="${existing_key_path%.pub}"
        if [[ -f "$private_key_path" ]]; then
          if ! ssh-add -l 2>/dev/null | grep -q "$private_key_path"; then
            echo "Adding key to SSH agent..."
            eval "$(ssh-agent -s)" > /dev/null 2>&1 || true
            ssh-add "$private_key_path" 2>/dev/null || echo "Note: Key not added to agent (may require passphrase)"
          fi
        fi
        ;;
      *)
        # Ask user for their email address
        echo "Please enter your email address:"
        read -p "> " email
        # Validate email format (basic check)
        if [[ ! "$email" =~ ^[^@]+@[^@]+\.[^@]+$ ]]; then
          echo "Error: Invalid email format"
          exit 1
        fi
        # Generate a new SSH key with an ed25519 curve
        echo "Generating a new SSH key..."
        key_path="$DEFAULT_KEY_PATH"
        if [ -f "$key_path" ]; then
          echo "SSH key already exists at $key_path"
          echo "Current key info:"
          ssh-keygen -lf "${key_path}.pub" 2>/dev/null || echo "Could not read existing key"
          read -p "Overwrite existing key? (y/N) [N]: " overwrite
          overwrite=${overwrite:-n}
          if [[ ! "$overwrite" =~ ^[yY]$ ]]; then
            echo "Using existing key instead of generating new one"
            public_key=$(cat "${key_path}.pub")
            # Add existing key to SSH agent
            if ! ssh-add -l 2>/dev/null | grep -q "$key_path"; then
              echo "Adding existing key to SSH agent..."
              eval "$(ssh-agent -s)" > /dev/null 2>&1 || true
              ssh-add "$key_path" 2>/dev/null || echo "Note: Key not added to agent (may require passphrase)"
            fi
          else
            # Backup existing key
            backup_path="${key_path}.backup.$(date +%s)"
            echo "Backing up existing key to $backup_path"
            cp "$key_path" "$backup_path" 2>/dev/null || true
            cp "${key_path}.pub" "${backup_path}.pub" 2>/dev/null || true
            # Generate new key
            if ! ssh-keygen -t ed25519 -C "$email" -f "$key_path"; then
              echo "Error: Failed to generate SSH key"
              exit 1
            fi
            public_key=$(cat "${key_path}.pub")
            # Add key to SSH agent
            echo "Adding new key to SSH agent..."
            eval "$(ssh-agent -s)" > /dev/null 2>&1 || true
            ssh-add "$key_path" 2>/dev/null || echo "Note: Key not added to agent (may require passphrase)"
          fi
        else
          # Create .ssh directory if it doesn't exist
          mkdir -p "$HOME/.ssh"
          chmod 700 "$HOME/.ssh"
          # Generate the key
          if ! ssh-keygen -t ed25519 -C "$email" -f "$key_path"; then
            echo "Error: Failed to generate SSH key"
            exit 1
          fi
          # Verify the key was created
          if [ ! -f "${key_path}.pub" ]; then
            echo "Error: SSH key generation failed"
            exit 1
          fi
          public_key=$(cat "${key_path}.pub")
          # Add key to SSH agent
          echo "Adding key to SSH agent..."
          eval "$(ssh-agent -s)" > /dev/null 2>&1 || true
          ssh-add "$key_path" 2>/dev/null || echo "Note: Key not added to agent (may require passphrase)"
        fi
        ;;
    esac
fi

# Validate public key content
if [ -z "$public_key" ]; then
  echo "Error: Could not read public key"
  exit 1
fi
# Validate public key format
if ! echo "$public_key" | ssh-keygen -lf - >/dev/null 2>&1; then
  echo "Error: Invalid public key format"
  exit 1
fi
# Print out the public key
echo ""
echo "Your public SSH key is:"
echo "----------------------------------------"
echo "$public_key"
echo "----------------------------------------"
# Show key fingerprint for verification
echo "Key fingerprint:"
echo "$public_key" | ssh-keygen -lf - 2>/dev/null || echo "Could not generate fingerprint"
# Copy to clipboard if available
clipboard_copied=false
if command -v xclip >/dev/null 2>&1; then
  echo "$public_key" | xclip -selection clipboard
  echo "Key copied to clipboard (xclip)"
  clipboard_copied=true
elif command -v pbcopy >/dev/null 2>&1; then
  echo "$public_key" | pbcopy
  echo "Key copied to clipboard (pbcopy)"
  clipboard_copied=true
elif command -v wl-copy >/dev/null 2>&1; then
  echo "$public_key" | wl-copy
  echo "Key copied to clipboard (wl-copy)"
  clipboard_copied=true
fi
if [[ "$clipboard_copied" = false ]]; then
  echo "Note: Copy the key above manually (no clipboard tool found)"
fi
# Ask user to configure the key in GitHub
echo ""
echo "Next steps:"
echo "1. Go to GitHub Settings: https://git.empdev.domo.com/settings/keys"
echo "2. Click 'New SSH key'"
echo "3. Paste the key above"
echo "4. Give it a descriptive title"
echo ""
# Check if key might already be on GitHub
read -p "Have you already added this key to GitHub? (y/N): " already_added
if [[ "$already_added" =~ ^[Yy]$ ]]; then
  echo "Testing connection..."
else
  read -p "Press Enter when you've added the key to GitHub..."
fi
# Test the connection
echo "Testing SSH connection to GitHub..."
set +e  # Temporarily disable exit on error
ssh_test_output=$(ssh -T git@git.empdev.domo.com -o ConnectTimeout=10 -o BatchMode=yes 2>&1)
set -e  # Re-enable exit on error
if echo "$ssh_test_output" | grep -q "successfully authenticated"; then
  username=$(echo "$ssh_test_output" | grep "successfully authenticated" | sed 's/.*Hi \([^!]*\)!.*/\1/')
  echo "SSH key successfully configured for GitHub user: $username"
elif echo "$ssh_test_output" | grep -q "Permission denied"; then
  echo "SSH connection failed - key not recognized by GitHub"
  echo "Please verify:"
  echo "1. The key was added correctly to GitHub"
  echo "2. You're using the correct GitHub account"
  echo "3. The key hasn't expired or been revoked"
else
  echo "SSH connection test inconclusive"
  echo "Output: $ssh_test_output"
  echo ""
  echo "You can test manually with: ssh -T git@git.empdev.domo.com"
  echo "Expected output should contain: 'successfully authenticated'"
fi
# Offer to set up git config if not already configured
if ! git config --global user.email >/dev/null 2>&1; then
  echo ""
  read -p "Git user email not configured. Set it up now? (Y/n): " setup_git
  if [[ ! "$setup_git" =~ ^[Nn]$ ]]; then
    if [[ -n "$email" ]]; then
      git config --global user.email "$email"
      echo "Set git user.email to: $email"
    else
      read -p "Enter your email for git commits: " git_email
      git config --global user.email "$git_email"
    fi
    read -p "Enter your name for git commits: " git_name
    git config --global user.name "$git_name"
    echo "Git configuration updated"
  fi
fi
