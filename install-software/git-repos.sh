#!/usr/bin/env bash
set -e

echo "Pull Git Repositories"

# Ask for target directory
read -rp "Target directory [/home/$USER/projects]: " target_dir
target_dir=${target_dir:-/home/$USER/projects}

# Expand tilde if needed
target_dir="${target_dir/#\~/$HOME}"

# Create directory if it doesn't exist
mkdir -p "$target_dir"

# List of repositories
REPOS=(
  "git@git.empdev.domo.com:Development/dataquerytools.git"
  "git@git.empdev.domo.com:Development/dataShared.git"
  "git@git.empdev.domo.com:Development/ice.git"
  "git@git.empdev.domo.com:Development/icebox.git"
  "git@git.empdev.domo.com:Development/datahub.git"
  "git@git.empdev.domo.com:Development/apiData.git"
  "git@git.empdev.domo.com:Development/apiAccounts.git"
  "git@git.empdev.domo.com:Development/apiOfThings.git"
)

cd "$target_dir"

# Process each repository
for repo_url in "${REPOS[@]}"; do
  repo_name=$(basename "$repo_url" .git)

  if [ -d "$repo_name" ]; then
    echo "Skipping $repo_name (already exists)"
  else
    echo "Cloning $repo_name..."
    git clone "$repo_url"
  fi
done

echo "Done! All repositories are in: $target_dir"
