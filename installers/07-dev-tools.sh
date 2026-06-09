# 07-dev-tools.sh — neovim, container runtime, languages, etc.

section "Dev Tools"

info "installing dev tools..."
install_pacman \
  neovim podman github-cli git-delta \
  go rust python python-poetry-core nodejs npm \
  git-filter-repo lua51 python-pynvim
install_aur lazygit lazydocker act mise opencode \
  stylua luarocks tree-sitter-cli tectonic nvimpager
[[ $DRY_RUN -eq 0 ]] && ok "dev tools" || true

if [[ $DRY_RUN -eq 1 ]]; then
  info "would run: mise install (install node, python, go, rust)"
else
  if command -v mise &>/dev/null; then
    mise install
    ok "mise tools installed"
  else
    warn "mise not found — skipping mise install"
  fi
fi

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

  if command -v docker &>/dev/null; then
    skip "docker command already available"
  else
    skip "docker/docker-compose wrappers will be symlinked by install.sh"
  fi
fi