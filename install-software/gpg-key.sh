#!/usr/bin/env bash
set -e
set -o pipefail

echo "Setup GPG key for GitHub"

# Check if GPG signing is already configured
GPG_CONFIGURED=false
CURRENT_SIGNING_KEY=""
COMMIT_SIGNING_ENABLED=false

# Check current git GPG configuration
if git config --global user.signingkey >/dev/null 2>&1; then
    CURRENT_SIGNING_KEY=$(git config --global user.signingkey)
    GPG_CONFIGURED=true
    echo "Found existing GPG signing key configured: $CURRENT_SIGNING_KEY"
fi

if git config --global commit.gpgsign >/dev/null 2>&1; then
    COMMIT_SIGNING_STATUS=$(git config --global commit.gpgsign)
    if [[ "$COMMIT_SIGNING_STATUS" == "true" ]]; then
        COMMIT_SIGNING_ENABLED=true
        echo "GPG commit signing is enabled"
    fi
fi

# Validate existing configuration
if [[ "$GPG_CONFIGURED" = true ]]; then
    # Check if the configured key actually exists
    if gpg --list-secret-keys --keyid-format LONG "$CURRENT_SIGNING_KEY" >/dev/null 2>&1; then
        echo "GPG key $CURRENT_SIGNING_KEY is valid and available"
        # Show key details
        key_info=$(gpg --list-secret-keys --keyid-format LONG "$CURRENT_SIGNING_KEY" 2>/dev/null | grep -A 1 "sec\|uid")
        echo "Current key details:"
        echo "$key_info" | head -3
        read -rp "GPG is already configured. Reconfigure anyway? (y/N): " reconfigure
        if [[ ! "$reconfigure" =~ ^[Yy]$ ]]; then
            echo "Skipping GPG configuration - already set up"
            # Ensure commit signing is enabled if not already
            if [[ "$COMMIT_SIGNING_ENABLED" = false ]]; then
                read -rp "Enable GPG commit signing? (Y/n): " enable_signing
                if [[ ! "$enable_signing" =~ ^[Nn]$ ]]; then
                    git config --global commit.gpgsign true
                    echo "✓ Enabled GPG commit signing"
                fi
            fi
            exit 0
        fi
    else
        echo "Configured GPG key $CURRENT_SIGNING_KEY not found in keyring"
        echo "Will help you set up a new key or configure an existing one"
    fi
fi

# List existing GPG keys
echo ""
echo "Checking for existing GPG keys..."
existing_keys=$(gpg --list-secret-keys --keyid-format LONG 2>/dev/null || true)

if [[ -n "$existing_keys" ]]; then
    echo "Found existing GPG keys:"
    echo "$existing_keys" | grep -E "(sec|uid)" | head -10
    echo ""
    read -rp "Use an existing GPG key? (Y/n): " use_existing
    if [[ ! "$use_existing" =~ ^[Nn]$ ]]; then
        gpg_choice="e"
    else
        gpg_choice="n"
    fi
else
    echo "No existing GPG keys found"
    gpg_choice="n"
fi

# Ask if the user wants to generate a new GPG key or use an existing one
if [[ -z "$gpg_choice" ]]; then
    echo "Do you want to generate a new GPG key or use an existing one?"
    read -rp "(n)ew or (e)xisting [n]: " gpg_choice
    gpg_choice=${gpg_choice:-n}
fi

case "$gpg_choice" in
  e|E)
    # Show available keys for easier selection
    echo ""
    echo "Available GPG keys:"
    gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -E "(sec|uid)" || echo "No keys found"
    echo ""
    # Ask for existing GPG key ID
    echo "Please enter your existing GPG key ID (e.g., ABC1234567890ABCD):"
    if [[ -n "$CURRENT_SIGNING_KEY" ]]; then
        read -rp "> [$CURRENT_SIGNING_KEY]: " gpg_key_id
        gpg_key_id=${gpg_key_id:-$CURRENT_SIGNING_KEY}
    else
        read -rp "> " gpg_key_id
    fi

    # Validate input
    if [[ -z "$gpg_key_id" ]]; then
      echo "Error: GPG key ID cannot be empty"
      exit 1
    fi

    # Clean up key ID (remove spaces, convert to uppercase)
    gpg_key_id=$(echo "$gpg_key_id" | tr -d ' ' | tr '[:lower:]' '[:upper:]')

    # Try exporting the public key
    if ! gpg_public_key=$(gpg --armor --export "$gpg_key_id" 2>/dev/null) || [[ -z "$gpg_public_key" ]]; then
      echo "Error: Could not find a GPG key with ID: $gpg_key_id"
      echo ""
      echo "Available keys:"
      gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -E "(sec|uid)" || echo "No secret keys found"
      echo ""
      echo "Use 'gpg --list-secret-keys --keyid-format LONG' to see all available keys"
      exit 1
    fi

    # Verify it's a secret key (can be used for signing)
    if ! gpg --list-secret-keys --keyid-format LONG "$gpg_key_id" >/dev/null 2>&1; then
      echo "Error: Key $gpg_key_id exists but is not a secret key (cannot be used for signing)"
      exit 1
    fi

    echo "Successfully found GPG key: $gpg_key_id"
    ;;
  *)
    # Check if we're about to generate a duplicate key
    echo "Generating a new GPG key..."
    echo "Please enter your name:"
    read -rp "> " gpg_name
    if [[ -z "$gpg_name" ]]; then
      echo "Error: Name cannot be empty"
      exit 1
    fi

    echo "Please enter your email address:"
    read -rp "> " gpg_email
    if [[ -z "$gpg_email" ]] || [[ ! "$gpg_email" =~ ^[^@]+@[^@]+\.[^@]+$ ]]; then
      echo "Error: Please enter a valid email address"
      exit 1
    fi

    # Check if a key already exists for this email
    set +e  # Temporarily disable exit on error
    existing_key_for_email=$(gpg --list-secret-keys --keyid-format LONG "$gpg_email" 2>/dev/null | awk '/sec/ {print $2}' | cut -d'/' -f2 | head -1)
    set -e  # Re-enable exit on error

    if [[ -n "$existing_key_for_email" ]]; then
      echo "Found existing GPG key for email $gpg_email: $existing_key_for_email"
      read -rp "Use existing key instead of generating new one? (Y/n): " use_existing_for_email
      if [[ ! "$use_existing_for_email" =~ ^[Nn]$ ]]; then
        gpg_key_id="$existing_key_for_email"
        gpg_public_key=$(gpg --armor --export "$gpg_key_id")
        echo "Using existing GPG key: $gpg_key_id"
      else
        # Generate new key with confirmation
        read -rp "This will create a second key for the same email. Continue? (y/N): " confirm_new
        if [[ ! "$confirm_new" =~ ^[Yy]$ ]]; then
          echo "Operation cancelled"
          exit 1
        fi
        generate_new_key=true
      fi
    else
      generate_new_key=true
    fi

    if [[ "$generate_new_key" = true ]]; then
      echo "Generating new GPG key..."
      echo "Note: You may be prompted for a passphrase (recommended for security)"

      # Create temporary config file for batch key generation
      temp_config=$(mktemp)
      cat > "$temp_config" <<EOF
Key-Type: eddsa
Key-Curve: ed25519
Name-Real: $gpg_name
Name-Email: $gpg_email
Expire-Date: 2y
%ask-passphrase
%commit
EOF

      # Generate GPG key with passphrase protection (more secure)
      set +e  # Temporarily disable exit on error for GPG generation
      if ! gpg --batch --gen-key "$temp_config"; then
        echo "Error: Failed to generate GPG key"
        echo "This might be due to insufficient entropy. Try moving your mouse or typing randomly."
        rm -f "$temp_config"
        exit 1
      fi
      set -e  # Re-enable exit on error

      # Clean up temporary file
      rm -f "$temp_config"

      # Get the newly created key ID
      sleep 2  # Give gpg a moment to update its database
      set +e  # Temporarily disable exit on error
      gpg_key_id=$(gpg --list-secret-keys --keyid-format LONG "$gpg_email" 2>/dev/null | awk '/sec/ {print $2}' | cut -d'/' -f2 | head -1)
      set -e  # Re-enable exit on error

      if [[ -z "$gpg_key_id" ]]; then
        echo "Error: Could not retrieve the generated key ID"
        echo "Trying alternative method..."
        set +e
        gpg_key_id=$(gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -A 1 "$gpg_email" | grep "sec" | awk '{print $2}' | cut -d'/' -f2)
        set -e
      fi

      if [[ -z "$gpg_key_id" ]]; then
        echo "Error: Could not retrieve the generated key ID"
        exit 1
      fi

      gpg_public_key=$(gpg --armor --export "$gpg_key_id")
      echo "Successfully generated GPG key with ID: $gpg_key_id"
    fi
    ;;
esac

# Validate we have a valid public key
if [[ -z "$gpg_public_key" ]]; then
  echo "Error: Could not export public key"
  exit 1
fi

# Configure Git to use this GPG key
echo ""
echo "Configuring Git to use GPG key: $gpg_key_id"

# Set the signing key
git config --global user.signingkey "$gpg_key_id"
echo "Set git signing key to: $gpg_key_id"

# Enable commit signing
git config --global commit.gpgsign true
echo "Enabled GPG commit signing"

# Test GPG signing
echo ""
echo "Testing GPG signing..."
set +e  # Temporarily disable exit on error for GPG test
if echo "test" | gpg --clearsign --default-key "$gpg_key_id" >/dev/null 2>&1; then
    echo "GPG signing test successful"
else
    echo "GPG signing test failed - you may need to enter your passphrase when making commits"
fi
set -e  # Re-enable exit on error

# Print the public GPG key
echo ""
echo "Your GPG public key is:"
echo "----------------------------------------"
echo "$gpg_public_key"
echo "----------------------------------------"

# Copy to clipboard if available
clipboard_copied=false
if command -v xclip >/dev/null 2>&1; then
  echo "$gpg_public_key" | xclip -selection clipboard
  echo "GPG key copied to clipboard (xclip)"
  clipboard_copied=true
elif command -v pbcopy >/dev/null 2>&1; then
  echo "$gpg_public_key" | pbcopy
  echo "GPG key copied to clipboard (pbcopy)"
  clipboard_copied=true
elif command -v wl-copy >/dev/null 2>&1; then
  echo "$gpg_public_key" | wl-copy
  echo "GPG key copied to clipboard (wl-copy)"
  clipboard_copied=true
fi

if [[ "$clipboard_copied" = false ]]; then
  echo "Note: Copy the key above manually (no clipboard tool found)"
fi

# Show key fingerprint for verification
echo ""
echo "Key fingerprint:"
set +e
gpg --fingerprint "$gpg_key_id" 2>/dev/null | grep -A 1 "Key fingerprint" || echo "Could not display fingerprint"
set -e

# Ask the user to configure their GPG key in GitHub
echo ""
echo "Next steps:"
echo "1. Go to GitHub Settings: https://git.empdev.domo.com/settings/keys"
echo "2. Click 'New GPG key'"
echo "3. Paste the GPG key above"
echo "4. Give it a descriptive title"
echo ""
echo "Current Git GPG configuration:"
echo "  Signing key: $(git config --global user.signingkey)"
echo "  Commit signing: $(git config --global commit.gpgsign)"
echo ""

read -rp "Press Enter when you've added the key to GitHub..."

# Test commit signing (optional)
read -rp "Test commit signing in a temporary repository? (Y/n): " test_signing
if [[ ! "$test_signing" =~ ^[Nn]$ ]]; then
    echo "Testing commit signing..."
    test_dir="/tmp/gpg-test-$$"
    if mkdir -p "$test_dir" && cd "$test_dir"; then
        git init >/dev/null 2>&1
        echo "test" > test.txt
        git add test.txt
        set +e  # Temporarily disable exit on error for test commit
        if git commit -m "Test GPG signing" >/dev/null 2>&1; then
            if git log --show-signature -1 2>&1 | grep -q "Good signature"; then
                echo "GPG commit signing is working correctly!"
            else
                echo "Commit was made but signature verification failed"
                echo "This is normal if the key isn't trusted yet"
            fi
        else
            echo "Test commit failed - you may need to configure your GPG agent"
        fi
        set -e  # Re-enable exit on error
        cd - >/dev/null
        rm -rf "$test_dir"
    else
        echo "Could not create test directory"
    fi
fi

echo ""
echo "GPG setup complete!"
echo "Your commits will now be signed with GPG key: $gpg_key_id"
