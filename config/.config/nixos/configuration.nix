{
  config,
  pkgs,
  options,
  ...
}: let
  hostname = "debbie"; # to alllow per-machine config
in {
  networking.hostName = hostname;

  imports = [
    /etc/nixos/hardware-configuration.nix
    (/home/nate/.config/nixos + "/${hostname}.nix")
  ];
}
