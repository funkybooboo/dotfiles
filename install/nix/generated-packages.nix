# Auto-generated NixOS package list
# Generated from dotfiles package installers
#
# Usage:
#   1. Copy this file to your NixOS configuration directory
#   2. Import in configuration.nix:
#        imports = [ ./generated-packages.nix ];
#   3. Run: sudo nixos-rebuild switch
#
# Or copy the package list directly into your configuration.nix

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bat
    fd
    lazygit
    neovim
  ];
}
