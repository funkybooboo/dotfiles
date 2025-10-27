#!/usr/bin/env bash

set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/log.sh"

log "Pull Git Repositories"

# Ask for target directory
read -rp "Target directory [/home/$USER/projects]: " target_dir
target_dir=${target_dir:-/home/$USER/projects}

# Expand tilde if present
target_dir="${target_dir/#\~/$HOME}"

# Create directory if it doesn't exist
mkdir -p "$target_dir"

# List of repositories to clone
REPOS=(
    "git@github.com:funkybooboo/university.git"
    "git@github.com:funkybooboo/problem_practice.git"
)

cd "$target_dir" || { log "Failed to change directory to $target_dir"; exit 1; }

# Process each repository
for repo_url in "${REPOS[@]}"; do
    repo_name=$(basename "$repo_url" .git)

    if [ -d "$repo_name" ]; then
        log "Skipping $repo_name (already exists)"
    else
        log "Cloning $repo_name..."
        git clone "$repo_url"
    fi
done

log "Done! All repositories are in: $target_dir"
