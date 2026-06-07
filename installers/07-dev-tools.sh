# 07-dev-tools.sh — neovim, container runtime, languages, etc.

section "Dev Tools"

info "installing dev tools..."
install_pacman \
  neovim podman github-cli git-delta \
  go rust python python-poetry-core nodejs npm
install_aur lazygit lazydocker act mise opencode \
  stylua luarocks tree-sitter-cli tectonic nvimpager
[[ $DRY_RUN -eq 0 ]] && ok "dev tools" || true

# Podman socket + group
if [[ $DRY_RUN -eq 1 ]]; then
  info "would enable: podman socket"
  info "would add $USER to podman group"
else
  if systemctl is-enabled --quiet podman.socket 2>/dev/null; then
    skip "podman.socket (already enabled)"
  else
    sudo systemctl enable --now podman.socket
    ok "podman.socket enabled"
  fi

  if command -v docker &>/dev/null && [[ -L "$(command -v docker)" ]]; then
    skip "docker/docker-compose symlinks (already present)"
  elif ! command -v docker &>/dev/null; then
    mkdir -p "$HOME/.local/bin"
    ln -sf /usr/bin/podman "$HOME/.local/bin/docker"
    ln -sf /usr/bin/podman "$HOME/.local/bin/docker-compose"
    ok "docker/docker-compose symlinks created (→ podman)"
  else
    skip "docker command already exists (not a symlink)"
  fi
fi