#!/usr/bin/env bash

# Package arrays for install-software/os.sh

APT_PACKAGES=(
  bat
  blanket
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
  procs
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
)

SNAP_CLASSIC_PACKAGES=(
  yazi
  codium
)

FLATPAK_PACKAGES=(
  com.github.tchx84.Flatseal
  com.hunterwittenborn.Celeste
  com.protonvpn.www
  me.proton.Pass
  org.freedesktop.Platform
  org.freedesktop.Platform.GL.default
  org.freedesktop.Platform.VAAPI.Intel
  org.freedesktop.Platform.codecs-extra
  org.freedesktop.Platform.openh264
  org.freedesktop.Sdk
  org.freedesktop.Sdk.Compat.i386
  org.gnome.Platform
  org.gtk.Gtk3theme.Greybird
  org.gtk.Gtk3theme.adw-gtk3
  org.gtk.Gtk3theme.adw-gtk3-dark
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
  signal-desktop-deb
  timeshift
)

HOMEBREW_PACKAGES=(
  Adembc/homebrew-tap/lazyssh
  lazydocker
  lazygit
  asdf
  nushell
)

PIP_PACKAGES=(

)

NPM_PACKAGES=(

)

GAH_PACKAGES=(

)
