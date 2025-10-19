#!/usr/bin/env bash

set -e
set -o pipefail

SEPARATOR="=============================================================="

echo "${SEPARATOR}"
./container-runtime-ui.sh
echo "${SEPARATOR}"

echo "${SEPARATOR}"
./java.sh
echo "${SEPARATOR}"

echo "${SEPARATOR}"
./jetbrains-toolbox.sh
echo "${SEPARATOR}"

echo "${SEPARATOR}"
./lightweight-code-editor.sh
echo "${SEPARATOR}"

echo "${SEPARATOR}"
./llm.sh
echo "${SEPARATOR}"

echo "${SEPARATOR}"
./vpn.sh
echo "${SEPARATOR}"

echo "${SEPARATOR}"
./git-ui.sh
echo "${SEPARATOR}"

echo "${SEPARATOR}"
./ssh-key.sh
echo "${SEPARATOR}"

echo "${SEPARATOR}"
read -p "Do you want to set up a GPG key? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ./gpg-key.sh
else
    echo "Skipping GPG key setup..."
fi
echo "${SEPARATOR}"

echo "${SEPARATOR}"
./git-repos.sh
echo "${SEPARATOR}"

echo "${SEPARATOR}"
./domo-tools.sh
echo "${SEPARATOR}"

echo "You really should reboot before continuing."
./reboot.sh
