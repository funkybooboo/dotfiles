#!/usr/bin/env bash

# Package arrays for install-software/ubuntu.sh

APT_PACKAGES=(
  bat
  chkrootkit
  clang
  clisp
  cmake
  cozy
  fish
  fzf
  gh
  git
  git-delta
  git-remote-gcrypt
  gnome-calculator
  gnome-disk-utility
  handbrake
  kitty
  lua5.1
  luarocks
  lynis
  mpv
  mtools
  net-tools
  ntfs-3g
  oathtool
  openconnect
  pandoc
  plocate
  power-profiles-daemon
  python3-poetry
  strace
  swig
  tree
  virt-manager
  wget
  xprintidle
  zoxide
  jq
  procps
  curl
  file
  termshark
  duf
  mtr
  eza
  glances
  ncdu
  errno
  fd-find
  ripgrep
  gdebi
  python-is-python3
)

SNAP_PACKAGES=(
  jump
  libreoffice
  mermaid-cli
  multipass
  rclone
  tldr
  zotero-snap
  elisa
  zoom-client
  blanket
  procs
  typst
  bruno
)

SNAP_CLASSIC_PACKAGES=(
  yazi
  codium
  #emacs
)

FLATPAK_PACKAGES=(
  com.github.tchx84.Flatseal
  com.hunterwittenborn.Celeste
  com.protonvpn.www
  me.proton.Pass
  io.podman_desktop.PodmanDesktop
  io.gitlab.librewolf-community
  com.brave.Browser
)

NIX_PACKAGES=(
  tectonic
  biber
  wikiman
)

CARGO_PACKAGES=(
  linutil_tui
)

GO_PACKAGES=(
  github.com/charmbracelet/glow@latest
)

PACSTALL_PACKAGES=(
  nala-deb
  neovim
  obsidian-deb
)

HOMEBREW_PACKAGES=(
  lazyssh
  lazydocker
  lazygit
  lazysql
  act
)

PIP_PACKAGES=(

)

NPM_PACKAGES=(
  @anthropic-ai/claude-code
  @marp-team/marp-cli
  opencode-ai@latest
)

GAH_PACKAGES=(

)
