{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.git
    pkgs.stow
    pkgs.jq
  ];

  shellHook = ''
    echo "🛠  Entered nix-shell with git, stow and jq available"
  '';
}

