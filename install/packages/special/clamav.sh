#!/usr/bin/env bash
# Install and configure ClamAV antivirus

set -euo pipefail

echo "=== Installing ClamAV ==="

# Detect package manager and install
if command -v pacman &>/dev/null; then
    # Arch Linux
    sudo pacman -S --needed --noconfirm clamav
elif command -v apt &>/dev/null; then
    # Debian/Ubuntu
    sudo apt update
    sudo apt install -y clamav clamav-daemon
elif command -v dnf &>/dev/null; then
    # Fedora
    sudo dnf install -y clamav clamav-update
else
    echo "Error: Unsupported package manager"
    exit 1
fi

echo "=== Configuring ClamAV ==="

# Stop services if running
sudo systemctl stop clamav-freshclam || true
sudo systemctl stop clamav-daemon || true

# Update virus definitions
echo "Updating virus definitions (this may take a while)..."
sudo freshclam

# Start and enable services
sudo systemctl start clamav-daemon
sudo systemctl enable clamav-daemon
sudo systemctl start clamav-freshclam
sudo systemctl enable clamav-freshclam

# Verify installation
echo ""
echo "=== ClamAV Installation Complete ==="
clamdscan --version

# Test scan
echo ""
echo "Testing ClamAV with a test file..."
echo "test" >/tmp/clamav-testfile
clamdscan /tmp/clamav-testfile
rm /tmp/clamav-testfile

# Set ACL to allow clamav user to read user's home directory
echo ""
echo "Setting up file access permissions for ClamAV..."
sudo setfacl -R -m u:clamav:rx "$HOME"

echo ""
echo "✓ ClamAV is installed and running!"
echo ""
echo "Useful commands:"
echo "  - Scan a directory: clamdscan /path/to/directory"
echo "  - Check status: systemctl status clamav-daemon"
echo "  - View logs: journalctl -u clamav-daemon"
