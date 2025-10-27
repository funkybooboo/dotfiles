#!/usr/bin/env bash
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/log.sh"
source "$SCRIPT_DIR/../utils/copy-to-clip-board.sh"  # provides copy_to_clipboard

log "Setup GPG key for GitHub"

# Defaults for non-interactive / headless environment
GPG_NAME=${GPG_NAME:-"nate"}
GPG_EMAIL=${GPG_EMAIL:-"nate.stott@pm.me"}

# Detect existing Git GPG configuration
CURRENT_SIGNING_KEY=$(git config --global user.signingkey || true)
COMMIT_SIGNING_ENABLED=$(git config --global commit.gpgsign || false)

# Check if current key exists
if [[ -n "$CURRENT_SIGNING_KEY" ]]; then
    log "Found existing GPG signing key: $CURRENT_SIGNING_KEY"
    if gpg --list-secret-keys --keyid-format LONG "$CURRENT_SIGNING_KEY" &>/dev/null; then
        log "Existing key is valid"
        if [[ "$COMMIT_SIGNING_ENABLED" != "true" ]]; then
            git config --global commit.gpgsign true
            log "Enabled GPG commit signing"
        fi
        exit 0
    else
        log "Configured GPG key $CURRENT_SIGNING_KEY not found. Proceeding to setup."
    fi
fi

# List existing keys
existing_keys=$(gpg --list-secret-keys --keyid-format LONG 2>/dev/null || true)
if [[ -n "$existing_keys" ]]; then
    log "Existing GPG keys found:"
    echo "$existing_keys" | grep -E "(sec|uid)" | head -10
    # Use the first existing key by default
    gpg_key_id=$(echo "$existing_keys" | awk '/sec/ {print $2}' | cut -d'/' -f2 | head -1)
    log "Using existing GPG key: $gpg_key_id"
else
    # Generate a new key
    log "Generating new GPG key for $GPG_NAME <$GPG_EMAIL>"
    temp_config=$(mktemp)
    cat > "$temp_config" <<EOF
Key-Type: eddsa
Key-Curve: ed25519
Name-Real: $GPG_NAME
Name-Email: $GPG_EMAIL
Expire-Date: 2y
%no-protection
%commit
EOF

    export GPG_TTY=$(tty)
    gpg --batch --pinentry-mode loopback --gen-key "$temp_config"
    rm -f "$temp_config"
    sleep 2

    gpg_key_id=$(gpg --list-secret-keys --keyid-format LONG "$GPG_EMAIL" | awk '/sec/ {print $2}' | cut -d'/' -f2 | head -1)
    gpg --list-secret-keys --keyid-format LONG "$gpg_key_id" &>/dev/null || { log "Failed to generate key"; exit 1; }
fi

# Export public key
gpg_public_key=$(gpg --armor --export "$gpg_key_id")
[[ -z "$gpg_public_key" ]] && { log "Failed to export GPG public key"; exit 1; }

# Configure Git
git config --global user.signingkey "$gpg_key_id"
git config --global commit.gpgsign true
log "Configured Git to use GPG key: $gpg_key_id"

# Copy public key to clipboard
copy_to_clipboard "$gpg_public_key"

# Show key fingerprint
gpg --fingerprint "$gpg_key_id" | grep -A 1 "Key fingerprint" || echo "Fingerprint not available"

log "Next steps: add your GPG key to GitHub: https://github.com/settings/keys"

# Pause and wait for user confirmation
read -rp "Press ENTER after you have added the GPG key to GitHub..."

log "GPG setup complete. Commits will be signed with: $gpg_key_id"
