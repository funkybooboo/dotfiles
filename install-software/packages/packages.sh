#!/usr/bin/env bash

# Package arrays for install-software/os.sh

APT_PACKAGES=(
  bat
  bubblewrap
  chkrootkit
  chrony
  clamav
  clang
  clisp
  cmake
  cozy
  distrobox
  fdclone
  fish
  fzf
  gh
  git
  git-delta
  git-remote-gcrypt
  gnome-calculator
  gnome-disk-utility
  guvcview
  handbrake
  kitty
  lua5.1
  luarocks
  lynis
  mate-polkit
  media-types
  mugshot
  mpv
  mtools
  net-tools
  ntfs-3g
  oathtool
  openconnect
  pandoc
  pipx
  plocate
  power-profiles-daemon
  python3-poetry
  rustup
  spice-vdagent
  strace
  swig
  thunar
  thunar-volman
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
)

SNAP_CLASSIC_PACKAGES=(
  yazi
  codium
  emacs
)

FLATPAK_PACKAGES=(
  com.github.tchx84.Flatseal
  com.hunterwittenborn.Celeste
  com.protonvpn.www
  me.proton.Pass
  io.podman_desktop.PodmanDesktop
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
  nushell
)

PIP_PACKAGES=(

)

NPM_PACKAGES=(
  @anthropic-ai/claude-code
)

GAH_PACKAGES=(

)
