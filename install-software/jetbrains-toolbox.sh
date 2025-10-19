#!/usr/bin/env bash

echo "Install JetBrains Toolbox"

INSTALL_DIR="$HOME/.local/share/JetBrains/Toolbox"
SYMLINK_DIR="$HOME/.local/bin"

# Get latest version
echo "Getting latest version info..."
API_RESPONSE=$(curl -s 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release')
ARCHIVE_URL=$(echo "$API_RESPONSE" | jq -r '.TBA[0].downloads.linux.link')
LATEST_VERSION=$(echo "$API_RESPONSE" | jq -r '.TBA[0].version')

echo "Latest version: $LATEST_VERSION"

# Check if already installed and compare versions
CURRENT_VERSION=""
if [[ -x "$INSTALL_DIR/bin/jetbrains-toolbox" ]]; then
    CURRENT_VERSION=$("$INSTALL_DIR/bin/jetbrains-toolbox" --version 2>/dev/null | grep -o '[0-9]\.[0-9]\.[0-9]' || echo "")
    if [[ -n "$CURRENT_VERSION" ]]; then
        echo "Current version: $CURRENT_VERSION"
        if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
            echo "Latest version already installed"
            # Still ensure symlink and PATH are set up correctly
            mkdir -p "$SYMLINK_DIR"
            ln -sf "$INSTALL_DIR/bin/jetbrains-toolbox" "$SYMLINK_DIR/jetbrains-toolbox"
            ./append_config.sh "export PATH=\"\$PATH:$SYMLINK_DIR\""
            # Launch if not already running
            if ! pgrep -f "jetbrains-toolbox" > /dev/null; then
                echo "Launching JetBrains Toolbox..."
                nohup "$INSTALL_DIR/bin/jetbrains-toolbox" >/dev/null 2>&1 &
            else
                echo "JetBrains Toolbox is already running"
            fi
            exit 0
        else
            echo "Updating from $CURRENT_VERSION to $LATEST_VERSION"
        fi
    fi
else
    echo "Installing JetBrains Toolbox for the first time"
fi

# Download
FILENAME=$(basename "$ARCHIVE_URL")
echo "Downloading $FILENAME..."
wget -q --show-progress -O "/tmp/$FILENAME" "$ARCHIVE_URL"

# Install
echo "Installing..."
mkdir -p "$INSTALL_DIR"
tar -xzf "/tmp/$FILENAME" -C "$INSTALL_DIR" --strip-components=1
rm "/tmp/$FILENAME"

# Setup symlink
mkdir -p "$SYMLINK_DIR"
chmod +x "$INSTALL_DIR/bin/jetbrains-toolbox"
ln -sf "$INSTALL_DIR/bin/jetbrains-toolbox" "$SYMLINK_DIR/jetbrains-toolbox"

# Add to PATH
./append_config.sh "export PATH=\"\$PATH:$SYMLINK_DIR\""

# Launch
echo "Launching JetBrains Toolbox..."
nohup "$INSTALL_DIR/bin/jetbrains-toolbox" >/dev/null 2>&1 &

if [[ -n "$CURRENT_VERSION" ]]; then
    echo "Updated! JetBrains Toolbox $CURRENT_VERSION → $LATEST_VERSION"
else
    echo "Done! JetBrains Toolbox $LATEST_VERSION installed"
fi
echo "Run 'source ~/.bashrc' to update PATH"
