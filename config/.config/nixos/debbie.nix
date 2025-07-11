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

    dynamicHosts = [
        {
            url = "https://someonewhocares.org/hosts/zero/hosts";
            sha256 = "1wyw6sa31rclv1wvmz8asfrs8hhgnx64m2c2hymbl0gk99000pnv";
        }
        {
            url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
            sha256 = "0mlx9l8k3mmx41hrlmqk6bibz8fvg6xzzpazkfizkc8ivw2nrgb7";
        }
        {
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt";
            sha256 = "1510gizap1rvjs8xm2vvgvr0r8vbsnj9q1cclm5zy3mr48blddr6";
        }
        {
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt";
            sha256 = "156jm8zgx5cgq6kxs73w5q4igwdrlkjs62nb12bwjlcjm4pxmf6b";
        }
    ];
    dynamicHostFiles = builtins.map (
        host:
            pkgs.fetchurl {
                inherit (host) url sha256;
            }
    )
    dynamicHosts;

    blockSites = [
        # Video & Streaming
        #"youtube.com"
        #"www.youtube.com"
        #"m.youtube.com"
        #"netflix.com"
        #"www.netflix.com"
        "sflix.to"
        "hulu.com"
        "www.hulu.com"
        "twitch.tv"
        "www.twitch.tv"
        "disneyplus.com"
        "www.disneyplus.com"
        "primevideo.com"
        "www.primevideo.com"
        "crunchyroll.com"
        "www.crunchyroll.com"
        "vimeo.com"
        "www.vimeo.com"
        "dailymotion.com"
        "www.dailymotion.com"
        "peacocktv.com"
        "www.peacocktv.com"

        # Social Media
        "facebook.com"
        "www.facebook.com"
        "instagram.com"
        "www.instagram.com"
        "tiktok.com"
        "www.tiktok.com"
        "twitter.com"
        "www.twitter.com"
        "x.com"
        "www.x.com"
        "pinterest.com"
        "www.pinterest.com"
        "tumblr.com"
        "www.tumblr.com"
        "snapchat.com"
        "www.snapchat.com"
        "bereal.com"
        "www.bereal.com"
        "threads.net"
        "www.threads.net"

        # News & Clickbait
        "cnn.com"
        "www.cnn.com"
        "foxnews.com"
        "www.foxnews.com"
        "nytimes.com"
        "www.nytimes.com"
        "washingtonpost.com"
        "www.washingtonpost.com"
        "buzzfeed.com"
        "www.buzzfeed.com"
        "dailymail.co.uk"
        "www.dailymail.co.uk"
        "news.yahoo.com"
        "yahoo.com"

        # Shopping & Marketplace
        "ebay.com"
        "www.ebay.com"
        "etsy.com"
        "www.etsy.com"
        "aliexpress.com"
        "www.aliexpress.com"
        "walmart.com"
        "www.walmart.com"
        "target.com"
        "www.target.com"
        "temu.com"
        "www.temu.com"
        "shein.com"
        "www.shein.com"

        # Casual & Browser Games
        #"store.steampowered.com"
        #"steampowered.com"
        "epicgames.com"
        "www.epicgames.com"
        "roblox.com"
        "www.roblox.com"
        "itch.io"
        "www.itch.io"
        "poki.com"
        "www.poki.com"
        "crazygames.com"
        "www.crazygames.com"
        "addictinggames.com"
        "www.addictinggames.com"
        "miniclip.com"
        "www.miniclip.com"

        # Misc distractions
        "9gag.com"
        "imgur.com"
        "buzzfeed.com"
        "boredpanda.com"
        "chess.com"
        "www.chess.com"
        "lichess.org"
        "www.lichess.org"
    ];

    allowedBinaries = [
        {
            name = "systemd-resolved";
            path = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-resolved";
        }
        {
            name = "systemd-timesyncd";
            path = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-timesyncd";
        }
        {
            name = "nix-daemon";
            path = "${lib.getBin pkgs.nix}/bin/nix-daemon";
        }
        {
            name = "nix";
            path = "${pkgs.nix}/bin/nix";
        }
        {
            name = "curl";
            path = "${pkgs.curl}/bin/curl";
        }
        {
            name = "wget";
            path = "${pkgs.wget}/bin/wget";
        }
        {
            name = "git";
            path = "${pkgs.git}/bin/git";
        }
        {
            name = "node";
            path = "${pkgs.nodejs}/bin/node";
        }
        {
            name = "python3";
            path = "${pkgs.python3}/bin/python3";
        }
        {
            name = "firefox";
            path = "${pkgs.firefox}/bin/firefox";
        }
    ];

    # Map to OpenSnitch rule format
    opensnitchRules = builtins.listToAttrs (map (entry: {
        name = entry.name;
        value = {
            name = entry.name;
            enabled = true;
            action = "allow";
            duration = "always";
            operator = {
                type = "simple";
                sensitive = false;
                operand = "process.path";
                data = entry.path;
            };
        };
    })
    allowedBinaries);
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
            checkReversePath = false;
        };
        hostFiles = dynamicHostFiles;
        hosts = {
            "0.0.0.0" = blockSites;
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
        sshguard = {
            enable = true; # turn on SSHGuard
            services = ["sshd"]; # which unit-logs to watch
            whitelist = [
                # networks never to block
                "192.168.0.0/16"
                "10.0.0.0/8"
            ];
            attack_threshold = 5; # points before blocking
            detection_time = 600; # seconds to accumulate points
            blocktime = 3600; # seconds to keep an IP blocked
            blacklist_threshold = 10; # auto-blacklist after N blocks
            blacklist_file = "/var/lib/sshguard/blacklist.db";
        };
        opensnitch = {
            enable = true;
            rules = opensnitchRules;
        };
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
            git-remote-gcrypt
            awstats
            linode-cli
            doctl
            azure-cli
            google-cloud-sdk
            aws-nuke
            awscli
            awsls
            awsume
            awsbck
            awslogs
            aws-mfa
            awsebcli
            aws-gate
            aws-shell
            wireguard-tools
            openvpn
            ipcalc
            nmap
            codecrafters-cli
            speedtest-cli
            rpi-imager
            opensnitch-ui

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
            protonvpn-cli
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
        steam = {
            enable = true;
            remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
            dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
            localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
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
            #     Environment = [
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
            #     OnCalendar   = "quarterly";
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
