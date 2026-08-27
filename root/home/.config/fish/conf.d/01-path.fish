# 01-path.fish -- PATH construction
#
# fish_add_path is idempotent and prepends by default, so re-sourcing this
# file (or re-running a session) never duplicates entries. User-local dirs
# are prepended so they win over system /usr/bin. Replaces the old
# conf.d/path.fish (which only added ~/.local/bin) and the inline PATH block
# that used to live in config.fish.

fish_add_path $HOME/.local/bin
fish_add_path $HOME/.luarocks/bin
fish_add_path /var/lib/flatpak/exports/share
fish_add_path $HOME/.local/share/flatpak/exports/share

# nix -- source the profile.d script (sets PATH, NIX_SSL_CERT_FILE,
# XDG_DATA_DIRS, NIX_PROFILES for nix-installed packages).
if test -f /etc/profile.d/nix-daemon.fish
    source /etc/profile.d/nix-daemon.fish
end
