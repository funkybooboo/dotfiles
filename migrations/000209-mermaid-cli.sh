# 000209-mermaid-cli.sh — Mermaid CLI (mmdc) for Snacks.image diagram rendering
# Installs: mermaid-cli (via nix — nixpkgs#mermaid-cli, provides mmdc)
# Links:    — (env vars live in ~/.config/environment.d/apps.conf, deployed by
#            000319-xdg.sh)
# Enables:  —
# Note: Snacks.image renders Mermaid code blocks in docs/markdown by shelling
#       out to `mmdc`. Without it, :checkhealth snacks reports
#       "❌ ERROR Tool not found: 'mmdc'".
#
#       mmdc drives puppeteer, which by default downloads its own ~150MB
#       Chromium at install time. We skip that (PUPPETEER_SKIP_DOWNLOAD=1,
#       set in apps.conf) and point puppeteer at the SYSTEM chromium
#       (PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium), which 000303-browsers.sh
#       installs. mmdc only needs chromium at *runtime* (when nvim renders a
#       diagram inside the graphical session), well after all migrations have
#       finished, so the 000303-vs-000209 ordering does not matter.
#
#       Previously installed via npm global (npm install -g). Now installed
#       via nix (nixpkgs#mermaid-cli) — hermetic, sandboxed, no npm global
#       package install. The nix package puts mmdc in ~/.nix-profile/bin/.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "mermaid cli"

install_nix nixpkgs#mermaid-cli
