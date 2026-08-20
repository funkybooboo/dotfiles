#!/usr/bin/env sh

# minecraft-launcher.sh -- wrapper for the official Mojang Minecraft launcher.
#
# Workaround for a stale CEF cache bug (MCL-25003 / KDE 501866): the launcher
# wedges if an old webcache2/CEF_VERSION file is left behind. Delete it before
# each launch so the launcher rebuilds it cleanly.
cef_version_file="$HOME/.minecraft/webcache2/CEF_VERSION"
if [ -e "$cef_version_file" ]; then
    rm "$cef_version_file"
fi

exec minecraft-launcher