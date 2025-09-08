#!/usr/bin/env bash
sleep 1
killall -e xdg-desktop-portal-hyprland
killall xdg-desktop-portal
xdg-desktop-portal-hyprland &
sleep 2
xdg-desktop-portal &
