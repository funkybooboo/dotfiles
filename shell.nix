{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.stow
    pkgs.jq
  ];

  shellHook = ''
    echo "🛠  Entered nix-shell with stow and jq available"
  '';
}

