# 07-dev-tools.sh — neovim, container runtime, languages, etc.

section "Dev Tools"

info "installing dev tools..."
run_cmd sudo pacman -S --needed --noconfirm \
  neovim podman github-cli git-delta \
  go rust python python-poetry-core nodejs npm
run_cmd yay -S --needed --noconfirm lazygit lazydocker act mise opencode \
  stylua luarocks tree-sitter-cli tectonic nvimpager
[[ $DRY_RUN -eq 0 ]] && ok "dev tools"

# Podman socket + group
if [[ $DRY_RUN -eq 1 ]]; then
  info "would enable: podman socket"
  info "would add $USER to podman group"
else
  sudo systemctl enable --now podman.socket
  ok "podman socket enabled"

  # Create docker/docker-compose symlinks to podman
  if ! command -v docker &>/dev/null || [[ -L "$(command -v docker)" ]]; then
    ln -sf /usr/bin/podman "$HOME/.local/bin/docker"
    ln -sf /usr/bin/podman "$HOME/.local/bin/docker-compose"
    ok "docker/docker-compose symlinks created (→ podman)"
  else
    skip "docker command already exists (not a symlink)"
  fi
fi