#!/usr/bin/env bash
set -euo pipefail

echo "Install Domo tools"

# Constants
readonly LOCAL_BIN_DIR="${HOME}/.local/bin"
readonly TUG_EKS_PATH="${LOCAL_BIN_DIR}/tug-eks"
readonly TUG_SYMLINK_PATH="${LOCAL_BIN_DIR}/tug"
readonly ROUTE_LOCAL_PATH="${LOCAL_BIN_DIR}/route-local"
readonly TUG_DOWNLOAD_URL="https://jenkins-k8s.domosoftware.net/job/CloudOps/job/rigs/job/tug-commit-eks-k8s/lastSuccessfulBuild/artifact/tug"

# Route-local script content
read -r -d '' ROUTE_LOCAL_CONTENT << 'EOF' || true
#!/usr/bin/env bash
# Examples:
#   route-local create ice
#   route-local delete ice

set -euo pipefail

# Service configuration
declare -A SERVICE_PORTS=(
    ["ice"]="8200"
    ["icebox"]="8250"
    ["datahub"]="8300"
    ["apiaccounts"]="9790"
)

# Check argument count
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <operation> <service>" >&2
    echo "Operations: create, delete" >&2
    echo "Services: ${!SERVICE_PORTS[*]}" >&2
    exit 1
fi

OPERATION=$1
SERVICE=$2

# Validation
if [[ "$OPERATION" != "create" && "$OPERATION" != "delete" ]]; then
    echo "Error: Invalid operation '$OPERATION'. Must be one of: create, delete." >&2
    exit 1
fi

if [[ ! "${SERVICE_PORTS[$SERVICE]:-}" ]]; then
    echo "Error: Invalid service '$SERVICE'. Must be one of: ${!SERVICE_PORTS[*]}." >&2
    exit 1
fi

# Execute operation
case "$OPERATION" in
    "delete")
        echo "tug delete route -s $SERVICE"
        tug delete route -s $SERVICE
        ;;
    "create")
        echo "tug delete route -s $SERVICE"
        tug delete route -s $SERVICE
        echo "tug create route -s $SERVICE -p ${SERVICE_PORTS[$SERVICE]}"
        tug create route -s $SERVICE -p ${SERVICE_PORTS[$SERVICE]}
        # Special case for ice service
        if [[ "$SERVICE" == "ice" ]]; then
            echo "tug set replicaCount -s ice -c 0"
            tug set replicaCount -s ice -c 0
        fi
        ;;
esac
EOF

# Cleanup function
cleanup() {
    if [[ -n "${temp_file:-}" ]] && [[ -f "$temp_file" ]]; then
        rm -f "$temp_file"
    fi
}
trap cleanup EXIT

# Create directory
mkdir -p "$LOCAL_BIN_DIR"

# Check if tug-eks is already installed and up to date
TUG_NEEDS_UPDATE=true
if [[ -f "$TUG_EKS_PATH" ]] && [[ -x "$TUG_EKS_PATH" ]]; then
    echo "Found existing tug-eks installation"

    # Try to get version info (if available) - with timeout to prevent hanging
    echo "Checking current version..."
    if TUG_VERSION=$(timeout 5s "$TUG_EKS_PATH" version 2>/dev/null || echo ""); then
        if [[ -n "$TUG_VERSION" && "$TUG_VERSION" != *"timeout"* ]]; then
            echo "Current tug-eks version: $TUG_VERSION"
        else
            echo "Current tug-eks: $(ls -la "$TUG_EKS_PATH" | awk '{print $5" bytes, modified "$6" "$7" "$8}')"
        fi
    else
        echo "Current tug-eks: $(ls -la "$TUG_EKS_PATH" | awk '{print $5" bytes, modified "$6" "$7" "$8}')"
    fi

    # Clear prompt with explicit output
    echo ""
    echo -n "tug-eks is already installed. Update to latest version? (Y/n): "
    read -r update_tug

    if [[ "$update_tug" =~ ^[Nn]$ ]]; then
        TUG_NEEDS_UPDATE=false
        echo "Keeping existing tug-eks installation"
    fi
fi

# Download/update tug-eks if needed
if [[ "$TUG_NEEDS_UPDATE" = true ]]; then
    echo "Downloading tug-eks from Jenkins..."
    # Download to temporary file first
    temp_file=$(mktemp)
    if curl -fsSL -o "$temp_file" "$TUG_DOWNLOAD_URL"; then
        # Verify the downloaded file is executable
        if file "$temp_file" | grep -q "executable\|ELF\|script"; then
            # Backup existing file if it exists
            if [[ -f "$TUG_EKS_PATH" ]]; then
                backup_path="${TUG_EKS_PATH}.backup.$(date +%s)"
                echo "Backing up existing tug-eks to $backup_path"
                cp "$TUG_EKS_PATH" "$backup_path"
            fi
            # Move new file into place
            mv "$temp_file" "$TUG_EKS_PATH"
            chmod u+x "$TUG_EKS_PATH"
            echo "tug-eks installed successfully"

            # Verify installation
            if [[ -x "$TUG_EKS_PATH" ]]; then
                echo "tug-eks is executable"
                # Try to get version if available (with timeout)
                if NEW_VERSION=$(timeout 5s "$TUG_EKS_PATH" version 2>/dev/null || echo ""); then
                    if [[ -n "$NEW_VERSION" ]]; then
                        echo "New tug-eks version: $NEW_VERSION"
                    fi
                fi
            else
                echo "tug-eks downloaded but may not be executable"
            fi
        else
            echo "Error: Downloaded file does not appear to be executable" >&2
            exit 1
        fi
    else
        echo "Error: Failed to download tug-eks" >&2
        exit 1
    fi
fi

# Create/update tug symlink
if [[ -L "$TUG_SYMLINK_PATH" ]]; then
    # Check if symlink points to the right place
    current_target=$(readlink "$TUG_SYMLINK_PATH")
    if [[ "$current_target" == "$TUG_EKS_PATH" ]]; then
        echo "tug symlink already exists and is correct"
    else
        echo "Updating tug symlink (was pointing to: $current_target)"
        rm "$TUG_SYMLINK_PATH"
        ln -s "$TUG_EKS_PATH" "$TUG_SYMLINK_PATH"
        echo "Updated tug symlink"
    fi
elif [[ -f "$TUG_SYMLINK_PATH" ]]; then
    echo "Warning: $TUG_SYMLINK_PATH exists but is not a symlink"
    echo -n "Replace with symlink to tug-eks? (Y/n): "
    read -r replace_tug

    if [[ ! "$replace_tug" =~ ^[Nn]$ ]]; then
        backup_path="${TUG_SYMLINK_PATH}.backup.$(date +%s)"
        echo "Backing up existing tug to $backup_path"
        mv "$TUG_SYMLINK_PATH" "$backup_path"
        ln -s "$TUG_EKS_PATH" "$TUG_SYMLINK_PATH"
        echo "Created tug symlink"
    fi
else
    ln -s "$TUG_EKS_PATH" "$TUG_SYMLINK_PATH"
    echo "Created tug symlink"
fi

# Check if route-local needs to be created or updated
ROUTE_LOCAL_NEEDS_UPDATE=true
if [[ -f "$ROUTE_LOCAL_PATH" ]]; then
    # Check if the content is the same
    if [[ -x "$ROUTE_LOCAL_PATH" ]] && diff -q <(echo "$ROUTE_LOCAL_CONTENT") "$ROUTE_LOCAL_PATH" >/dev/null 2>&1; then
        echo "route-local script is already up to date"
        ROUTE_LOCAL_NEEDS_UPDATE=false
    else
        echo "Found existing route-local script with different content"
        echo -n "Update route-local script? (Y/n): "
        read -r update_route_local

        if [[ "$update_route_local" =~ ^[Nn]$ ]]; then
            ROUTE_LOCAL_NEEDS_UPDATE=false
            echo "Keeping existing route-local script"
        else
            # Backup existing script
            backup_path="${ROUTE_LOCAL_PATH}.backup.$(date +%s)"
            echo "Backing up existing route-local to $backup_path"
            cp "$ROUTE_LOCAL_PATH" "$backup_path"
        fi
    fi
fi

# Create/update route-local script if needed
if [[ "$ROUTE_LOCAL_NEEDS_UPDATE" = true ]]; then
    echo "Creating route-local script..."
    echo "$ROUTE_LOCAL_CONTENT" > "$ROUTE_LOCAL_PATH"
    chmod +x "$ROUTE_LOCAL_PATH"
    echo "route-local script installed successfully"
fi

# Verify installations
echo ""
echo "=== Verifying Domo tools installation ==="
if [[ -x "$TUG_EKS_PATH" ]]; then
    echo "tug-eks: $(ls -la "$TUG_EKS_PATH" | awk '{print $5" bytes"}')"
else
    echo "tug-eks: Not found or not executable"
fi

if [[ -L "$TUG_SYMLINK_PATH" ]] && [[ -e "$TUG_SYMLINK_PATH" ]]; then
    echo "tug symlink: Points to $(readlink "$TUG_SYMLINK_PATH")"
else
    echo "tug symlink: Not found or broken"
fi

if [[ -x "$ROUTE_LOCAL_PATH" ]]; then
    echo "route-local: Available"
else
    echo "route-local: Not found or not executable"
fi

./append_config.sh "export PATH=\"\$PATH:$LOCAL_BIN_DIR\""

echo "Added $LOCAL_BIN_DIR to PATH"
echo "Note: Restart your shell or run 'source ~/.bashrc' to update PATH"

echo ""
echo "Domo tools installation complete!"
echo ""
echo "Available commands:"
echo "  - tug-eks: Main tug binary"
echo "  - tug: Symlink to tug-eks"
echo "  - route-local: Helper script for local routing"
echo ""
echo "Usage examples:"
echo "  route-local create ice"
echo "  route-local delete ice"
echo "  tug --help"

# Configure UFW to allow incoming traffic to service ports
echo ""
echo "=== Configuring UFW firewall rules ==="

# Check if UFW is available
if command -v ufw >/dev/null 2>&1; then
    echo "Configuring UFW rules for service ports..."
    
    sudo ufw allow 8200/tcp comment "Domo ice service"
    sudo ufw allow 8250/tcp comment "Domo icebox service"
    sudo ufw allow 8300/tcp comment "Domo datahub service"
    sudo ufw allow 9790/tcp comment "Domo apiaccounts service"
    
    echo "UFW rules configured successfully"
    echo "Active UFW rules for Domo services:"
    sudo ufw status | grep -E "(8200|8250|8300|9790)" || echo "No matching rules found"
else
    echo "UFW not found - skipping firewall configuration"
    echo "You may need to manually configure your firewall to allow ports: 8200 8250 8300 9790"
fi

