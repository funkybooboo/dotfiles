#!/usr/bin/env bash

set -e
set -o pipefail

SEPARATOR="=============================================================="

echo "${SEPARATOR}"
./update.sh
echo "${SEPARATOR}"

echo "${SEPARATOR}"
./basic-tools.sh
echo "${SEPARATOR}"

echo "${SEPARATOR}"
./cuda.sh
echo "${SEPARATOR}"

echo "${SEPARATOR}"
./container-runtime.sh
echo "${SEPARATOR}"

echo "You really should reboot before continuing."
./reboot.sh
