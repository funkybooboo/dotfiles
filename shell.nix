{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.git
    pkgs.jq
  ];

  shellHook = ''
    echo "🛠  Entered nix-shell with git and jq available"
  '';
}

