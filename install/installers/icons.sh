#/usr/bin/env bash
set -e
set -o pipefail

sudo add-apt-repository ppa:papirus/papirus
sudo apt-get update
sudo apt-get install papirus-icon-theme # Papirus, Papirus-Dark, and Papirus-Light
