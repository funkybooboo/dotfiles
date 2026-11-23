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
            exercism codecrafters-cli opencode herdr
            # digital: hneemann's digital circuit simulator. Not in Arch's
            # official repos, so nix is the first tier that can provide it.
            digital
            # ungoogled-chromium: privacy-hardened chromium (Google
            # integration/updater/telemetry stripped). Arch's official repos
            # don't carry it (AUR only, excluded by policy), Flathub doesn't
            # carry it, and upstream's portable-linux assets run weeks stale
            # with no published checksums -- so nix is the first tier that
            # can serve it. Binary-cache hit dry-run-verified (166 MiB
            # fetched, nothing built); free, so hydra builds it continuously,
            # unlike unfree brave which every nix install compiles locally.
            # Same upstream release as Arch's chromium (000309).
            ungoogled-chromium
            # espanso-wayland: text expander, Wayland build. Not in Arch's
            # official repos, and upstream's only Linux Wayland asset is a Debian
            # .deb, so tier 2 cannot serve Arch at all. AUR does carry
            # espanso-wayland 2.4.0, but AUR is excluded by policy, which leaves
            # nix as the first tier able to provide it.
            espanso-wayland;
        });
    };
}
