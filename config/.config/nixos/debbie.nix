{
    config,
    pkgs,
    lib,
    ...
}: let
    unstableTarball = fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
    };

    mysqlInitScript = pkgs.writeTextFile {
        name = "mariadb-init";
        text = lib.concatStringsSep "\n" [
            "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';"
            "FLUSH PRIVILEGES;"
        ];
    };

    flatpakApps = [
        "io.github.voxelcubes.hand-tex"
        "io.github.dman95.SASM"
        "io.gitlab.persiangolf.voicegen"
        "org.kde.kgeography"
        "org.kde.isoimagewriter"
        "io.github.josephmawa.EncodingExplorer"
        "eu.jumplink.Learn6502"
    ];
    flatpakAppList = lib.concatStringsSep " " flatpakApps;
in {
    # Bootloader
    boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
    };

    # Networking
    networking = {
        networkmanager.enable = true;
        firewall = {
            enable = true;
            allowedTCPPorts = [];
            allowedUDPPorts = [];
        };
    };

    # Time
    time.timeZone = "America/New_York";
    #time.timeZone = "America/Denver";

    # Internationalisation
    i18n = {
        defaultLocale = "en_US.UTF-8";
        extraLocaleSettings = {
            LC_ADDRESS = "en_US.UTF-8";
            LC_IDENTIFICATION = "en_US.UTF-8";
            LC_MEASUREMENT = "en_US.UTF-8";
            LC_MONETARY = "en_US.UTF-8";
            LC_NAME = "en_US.UTF-8";
            LC_NUMERIC = "en_US.UTF-8";
            LC_PAPER = "en_US.UTF-8";
            LC_TELEPHONE = "en_US.UTF-8";
            LC_TIME = "en_US.UTF-8";
        };
    };

    # Security
    security.rtkit.enable = true;

    # Services
    services = {
        xserver = {
            enable = true;
            xkb = {
                layout = "us";
                variant = "";
            };
        };
        displayManager = {
            sddm = {
                enable = true;
                wayland.enable = true;
            };
            defaultSession = "plasma";
        };
        desktopManager.plasma6.enable = true;
        pulseaudio.enable = false;
        pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
        };
        printing.enable = true;
        mysql = {
            enable = true;
            package = pkgs.mariadb;
            initialScript = toString mysqlInitScript;
        };
        systembus-notify.enable = true;
        locate.enable = true;
        fwupd.enable = true;
        openssh.enable = true;
        libinput.enable = true;
        flatpak.enable = true;
    };

    # Hardware
    hardware = {
        bluetooth = {
            enable = true;
            powerOnBoot = true;
        };
        graphics = {
            enable = true;
            enable32Bit = true;
        };
    };

    # Users
    ## Don't forget to set a password with ‘passwd’
    users = {
        users = {
            nate = {
                isNormalUser = true;
                description = "Nate Stott";
                extraGroups = ["networkmanager" "wheel" "wireshark" "docker"];
                shell = pkgs.fish;
            };
        };
        extraGroups = {
            vboxusers = {
                members = ["nate"];
            };
        };
    };

    # Nixpkgs
    nixpkgs.config = {
        permittedInsecurePackages = [];
        allowUnfree = true;
        packageOverrides = pkgs: {
            unstable = import unstableTarball {
                config = config.nixpkgs.config;
            };
        };
    };

    xdg.portal = {
        enable = true;
        extraPortals = [
            pkgs.xdg-desktop-portal
            pkgs.xdg-desktop-portal-gtk
            pkgs.xdg-desktop-portal-hyprland
        ];
    };

    # Environment
    environment = {
        systemPackages = with pkgs; [
            # Development
            go
            python313
            python312Packages.pip
            php
            php84Packages.composer
            typescript
            deno
            julia
            sbcl
            gfortran
            gnat14
            zig
            rustlings
            rustup
            rustfmt
            fnm
            zulu23
            lua51Packages.lua
            luajitPackages.luarocks-nix
            dotnetCorePackages.sdk_9_0
            maven
            gradle
            cmake
            gnumake
            poetry
            black
            clang-tools
            tree-sitter
            postman
            newman
            bruno-cli
            bruno
            stripe-cli

            # Editors & IDEs
            neovim
            vscodium
            unstable.jetbrains.datagrip
            unstable.jetbrains.webstorm
            unstable.jetbrains.rust-rover
            unstable.jetbrains.rider
            unstable.jetbrains.pycharm-professional
            unstable.jetbrains.idea-ultimate
            unstable.jetbrains.goland
            unstable.jetbrains.clion

            # Shell & CLI Utilities
            fish
            kitty
            fzf
            fd
            ripgrep
            jump
            zoxide
            tmux
            tree
            bat
            imgcat
            cloc
            lsd
            ascii
            file
            unixtools.xxd
            unixtools.quota
            bc
            zip
            unzip
            xclip
            cliphist
            jq
            yq
            tldr
            wikiman
            glow
            fastfetch
            htop-vim
            sysstat
            yazi
            batmon
            kondo
            wiper
            oath-toolkit
            xprintidle
            pciutils
            direnv
            mtr
            mtr-gui
            pmutils

            # Version Control
            git
            glab
            codeberg-cli
            gh
            github-desktop
            lazygit
            git-filter-repo
            gitbutler
            delta

            # Containerization & Deployment
            lazydocker
            nix-init
            stow
            unetbootin
            rclone

            # Browsers & Communication
            firefox
            unstable.librewolf
            brave
            chromium
            lynx
            signal-desktop
            unstable.jami
            protonmail-bridge-gui
            proton-pass
            protonvpn-gui
            webcord
            zoom-us
            thunderbird

            # Networking & Security
            openssl
            curl
            wget
            wireshark
            ethtool
            iw
            wirelesstools

            # Media & Graphics
            mpv
            ffmpeg
            asciinema
            espeak
            viewnior
            imagemagick
            timg
            drawio
            zathura
            poppler_utils
            asciiquarium
            aalib
            oneko
            easyeffects
            playerctl
            pavucontrol
            imaginer

            # Office & Productivity
            libreoffice
            obsidian
            pomodoro-gtk
            pandoc
            texliveTeTeX
            deskreen
            memorado
            varia
            blanket

            # System & Desktop
            gparted
            xdg-desktop-portal
            xdg-desktop-portal-gtk
            xdg-desktop-portal-hyprland
            networkmanagerapplet
            wofi
            waybar
            hyprsunset
            hyprpaper
            hyprpicker
            hyprlandPlugins.hyprbars
            hyprlandPlugins.hyprexpo
            power-profiles-daemon
            swaynotificationcenter
            libnotify
            hyprpolkitagent
            hypridle
            brightnessctl
            hyprlock
            nwg-look
            wlogout
            hyprshot
            libsForQt5.xwaylandvideobridge
            kdePackages.plasma-workspace
            kdePackages.breeze
            kdePackages.plasma-desktop

            # Fonts & Themes
            alejandra
            font-awesome
            comic-mono
            catppuccin-cursors
            catppuccin-papirus-folders
            papirus-folders
            kdePackages.breeze-gtk
            kdePackages.breeze-icons
            kdePackages.breeze.qt5
            kdePackages.breeze

            # Assembly & Low-level Tools
            nasm
            nasmfmt
            asmrepl
            asmjit
            uasm
            gdb
            gdbgui
            libgcc

            # Database & Data Tools
            sqlite
            dbeaver-bin

            # Gaming
            chess-tui
            stockfish

            # AI
            alpaca

            # Learning
            nix-tour
            keypunch

            # Miscellaneous
            chance
            devtoolbox
            concessio
        ];
        sessionVariables = {
            NIXOS_OZONE_WL = "1";
        };
        variables = {
            EDITOR = "nvim";
        };
        plasma6.excludePackages = with pkgs.kdePackages; [
            plasma-browser-integration
            konsole
            #(lib.getBin qttools) # Expose qdbus in PATH
            # ark
            # elisa
            #gwenview
            #okular
            # kate
            khelpcenter
            #dolphin
            baloo-widgets # baloo information in Dolphin
            dolphin-plugins
            #spectacle
            ffmpegthumbs
            krdp
            #xwaylandvideobridge # exposes Wayland windows to X11 screen capture
        ];
    };

    # Programs
    programs = {
        fish.enable = true;
        mtr.enable = true;
        neovim = {
            enable = true;
            viAlias = true;
            vimAlias = true;
        };
        gnupg = {
            agent = {
                enable = true;
                enableSSHSupport = true;
            };
        };
        nix-ld = {
            enable = true;
            libraries = with pkgs; [
                # Add any missing dynamic libraries for unpackaged programs here,
                # NOT in environment.systemPackages
            ];
        };
        hyprland = {
            enable = true;
            xwayland = {
                enable = true;
            };
        };
    };

    # Virtualization
    virtualisation = {
        virtualbox = {
            host = {
                enable = true;
                enableExtensionPack = true;
                addNetworkInterface = false;
                enableKvm = true;
            };
            guest = {
                enable = true;
                dragAndDrop = true;
                clipboard = true;
            };
        };
        docker = {
            enable = true;
        };
        multipass = {
            enable = true;
        };
    };

    # Fonts
    fonts = {
        enableDefaultPackages = true;
        packages = with pkgs; [
            nerd-fonts.open-dyslexic
            nerd-fonts.fira-code
            nerd-fonts.droid-sans-mono
            nerd-fonts.jetbrains-mono
        ];
        fontconfig = {
            useEmbeddedBitmaps = true;
        };
    };

    # Systemd
    systemd = {
        services = {
            install-flatpaks = {
                description = "Install Flatpak apps from Flathub";
                wantedBy = ["multi-user.target"];
                after = ["flatpak-system-helper.service"];
                serviceConfig = {
                    Type = "oneshot";
                    Environment = "PATH=/run/current-system/sw/bin:/run/wrappers/bin:/etc/profiles/per-user/root/bin";
                    ExecStart = pkgs.writeShellScript "install-flatpaks" ''
                        set -e

                        # Ensure flatpak is installed
                        if ! command -v flatpak >/dev/null; then
                          echo "Flatpak command not found! Skipping Flatpak app installation."
                          exit 0
                        fi

                        # Make sure flathub is added
                        if ! flatpak remote-list | grep -q flathub; then
                          echo "Adding Flathub remote..."
                          flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
                        fi

                        # Install apps
                        for app in ${flatpakAppList}; do
                          echo "Installing $app..."
                          if ! flatpak info "$app" >/dev/null 2>&1; then
                            flatpak install -y --noninteractive flathub "$app"
                          else
                            echo "$app already installed."
                          fi
                        done

                        # Cleanup apps not in list
                        echo "Checking for orphaned Flatpak apps..."
                        for installed in $(flatpak list --app --columns=application); do
                          if ! echo "${flatpakAppList}" | grep -qw "$installed"; then
                            echo "Removing orphaned app: $installed"
                            flatpak uninstall -y "$installed"
                          fi
                        done
                    '';
                    StandardOutput = "journal";
                    StandardError = "journal";
                };
            };

            sync-docs = {
                description = "Sync ~/Documents with Proton Drive via rclone bisync";
                wants = ["network-online.target"];
                after = ["network-online.target"];
                serviceConfig = {
                    Type = "simple";
                    User = "nate";
                    Environment = [
                        "HOME=/home/nate"
                        "USER=nate"
                        "PATH=/run/current-system/sw/bin:/home/nate/.local/bin"
                    ];
                    ExecStart = "${pkgs.bash}/bin/bash /home/nate/.local/bin/sync-docs";
                    Restart = "on-failure";
                    RestartSec = 300;
                    StandardOutput = "journal";
                    StandardError = "journal";
                };
            };

            auto-update = {
                description = "Headless NixOS auto-update (battery, idle & load checks)";
                wants = ["network-online.target"];
                after = ["network-online.target"];
                serviceConfig = {
                    Type = "simple";
                    Environment = [
                        "HOME=/home/nate"
                        "USER=nate"
                        "PATH=/run/current-system/sw/bin:/home/nate/.local/bin"
                    ];
                    ExecStart = "${pkgs.bash}/bin/bash /home/nate/.local/bin/auto-update";
                    Restart = "on-failure";
                    RestartSec = 300;
                    StandardOutput = "journal";
                    StandardError = "journal";
                };
            };

            backup-github = {
                description = "Mirror all GitHub repos to GitLab + Proton Drive";
                wants = ["network-online.target"];
                after = ["network-online.target"];
                serviceConfig = {
                    Type = "simple";
                    User = "nate";
                    Environment = [
                        "HOME=/home/nate"
                        "USER=nate"
                        "PATH=/run/current-system/sw/bin:/home/nate/.local/bin"
                    ];
                    ExecStart = "${pkgs.bash}/bin/bash /home/nate/.local/bin/backup-github";
                    Restart = "on-failure";
                    RestartSec = 3600;
                    StandardOutput = "journal";
                    StandardError = "journal";
                };
            };

            # auto-update-firmware = {
            #   description = "Auto-update firmware via fwupd when idle/on AC";
            #   wants        = [ "network-online.target" ];
            #   after        = [ "network-online.target" ];
            #   serviceConfig = {
            #     Type        = "oneshot";
            #     User        = "nate";
            #     Environment = [
            #       "HOME=/home/nate"
            #       "USER=nate"
            #       "PATH=/run/current-system/sw/bin:/home/nate/.local/bin"
            #     ];
            #     ExecStart   = "/run/current-system/sw/bin/bash /home/nate/.local/bin/auto-update-firmware";
            #     StandardOutput = "journal";
            #     StandardError  = "journal";
            #   };
            # };
        };

        timers = {
            sync-docs = {
                description = "Hourly trigger for sync-docs.service";
                wantedBy = ["timers.target"];
                timerConfig = {
                    OnCalendar = "hourly";
                    Persistent = true;
                };
            };

            auto-update = {
                description = "Headless NixOS auto-update (battery, idle & load checks)";
                wantedBy = ["timers.target"];
                timerConfig = {
                    OnCalendar = "daily";
                    Persistent = true;
                };
            };

            backup-github = {
                description = "Headless mirror of GitHub repos to GitLab + Proton Drive";
                wantedBy = ["timers.target"];
                timerConfig = {
                    OnCalendar = "weekly";
                    Persistent = true;
                };
            };

            # auto-update-firmware = {
            #   description = "Periodic trigger for auto-update-firmware.service";
            #   wants       = [ "timers.target" ];
            #   timerConfig = {
            #     OnCalendar   = "monthly";
            #     Persistent   = true;
            #   };
            # };
        };
    };

    # System
    system = {
        stateVersion = "25.05"; # see https://ostechnix.com/upgrade-nixos/
    };
}
