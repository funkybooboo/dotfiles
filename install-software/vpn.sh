#!/usr/bin/env bash

set -e

echo "Installing lobalProtect OpenConnect ..."

# https://github.com/yuezk/GlobalProtect-openconnect
# https://github.com/dlenski/gp-saml-gui
# https://wikidev.domo.com/confluence/display/devwiki/VPN+Access

# Add PPA (silently skip if exists)
sudo add-apt-repository -y ppa:yuezk/globalprotect-openconnect 2>/dev/null || true

# Update package list
sudo apt update

# Install
sudo apt install -y globalprotect-openconnect

echo "GlobalProtect OpenConnect is installed!"
