{
  description = "Dotfiles nix packages -- allows unfree, pinned nixpkgs revision";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAll = nixpkgs.lib.genAttrs systems;
      pkgsFor = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      packages = forAll (system:
        let pkgs = pkgsFor system; in {
          inherit (pkgs)
            brave librewolf wayfreeze tdf timg nvimpager
            proton-pass-cli losslesscut cliamp lazyjournal lazysql
            calcure mermaid-cli bitwarden-cli pi-coding-agent vscode
            exercism codecrafters-cli
            # Added for Debian/Ubuntu, where these have no archive package and
            # no upstream Linux release asset. Unused on Arch (pacman covers
            # them there), but harmless -- an unreferenced attr costs nothing.
            ast-grep bluetui fastfetch hyprlauncher hyprsunset impala
            tectonic wiremix;

          # waybar 0.15.0 (nixpkgs) + PR #5013: Hyprland Lua-IPC dispatch fix so
          # the native hyprland/workspaces module's click works under Hyprland's
          # Lua config. Upstream merged on master but no release tag ships it yet;
          # nixpkgs still pins 0.15.0. Drop this override once nixpkgs waybar
          # includes #5013. The PR's new tests are pure (no socket) and pass.
          waybar = pkgs.waybar.overrideAttrs (prev: {
            patches = (prev.patches or [ ]) ++ [ ./overlays/waybar-pr5013.patch ];
          });
        });
    };
}
