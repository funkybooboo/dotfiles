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
        "net.mkiol.SpeechNote"
        "org.kde.kgeography"
        "org.kde.isoimagewriter"
        "io.github.josephmawa.EncodingExplorer"
        "com.github.arshubham.gitignore"
        "net.jami.Jami"
        "eu.fortysixandtwo.chessclock"
        "io.github.amit9838.mousam"
        "com.github.xournalpp.xournalpp"
    ];
    flatpakAppList = lib.concatStringsSep " " flatpakApps;

    dynamicHosts = [
        {
            url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts";
            sha256 = "1g9cjfi529vz1jdxm7z1wj5xvr459334ip1np73w5yklyx0m9c8n";
        }
        {
            url = "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt";
            sha256 = "06nv4mwfshhb2w0d9qg0nn6vqhh3qkls8nx1ifybkx8jfd1lchxx";
        }
        {
            url = "https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt";
            sha256 = "1c0r0ljjnzial613yzq2lpzr2r3f1mrqaki8r94azz1rwx9zzcsz";
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
        # "youtube.com"
        # "www.youtube.com"
        # "m.youtube.com"
        # "netflix.com"
        # "www.netflix.com"
        # "sflix.to"
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
        "funimation.com"
        "www.funimation.com"
        "animelab.com"
        "www.animelab.com"
        "kick.com"
        "www.kick.com"
        "rumble.com"
        "www.rumble.com"
        "odysee.com"
        "www.odysee.com"
        "metacafe.com"
        "www.metacafe.com"
        "newgrounds.com"
        "www.newgrounds.com"
        "www.pornhub.com"
        "pornhub.com"

        # Social Media & Messaging
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
        # "reddit.com"
        # "www.reddit.com"
        # "old.reddit.com"
        # "new.reddit.com"
        # "quora.com"
        # "www.quora.com"
        # "linkedin.com"
        # "www.linkedin.com"
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
        # "discord.com"
        # "www.discord.com"
        "slack.com"
        "www.slack.com"
        "kakao.com"
        "www.kakao.com"
        "weibo.com"
        "www.weibo.com"
        "vk.com"
        "www.vk.com"
        "line.me"
        "www.line.me"

        # News, Aggregators & Clickbait
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
        "msn.com"
        "www.msn.com"
        "news.google.com"
        "flipboard.com"
        "feedly.com"
        "apple.news"
        "drudgereport.com"
        "breitbart.com"
        "theguardian.com"
        "www.theguardian.com"
        "npr.org"
        "www.npr.org"

        # Shopping & Marketplaces
        #"amazon.com"
        #"www.amazon.com"
        #"ebay.com"
        #"www.ebay.com"
        "etsy.com"
        "www.etsy.com"
        "aliexpress.com"
        "www.aliexpress.com"
        #"walmart.com"
        #"www.walmart.com"
        "target.com"
        "www.target.com"
        "temu.com"
        "www.temu.com"
        "shein.com"
        "www.shein.com"
        "slickdeals.net"
        "www.slickdeals.net"
        "dealnews.com"
        "www.dealnews.com"
        "groupon.com"
        "www.groupon.com"
        "rakuten.com"
        "www.rakuten.com"
        "newegg.com"
        "www.newegg.com"
        "bhphotovideo.com"
        "www.bhphotovideo.com"

        # Browser & Casual Games
        # "store.steampowered.com"
        # "steampowered.com"
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
        "kongregate.com"
        "www.kongregate.com"
        "nitrome.com"
        "www.nitrome.com"
        "y8.com"
        "www.y8.com"
        "armorgames.com"
        "www.armorgames.com"
        "shockwave.com"
        "www.shockwave.com"
        "popcap.com"
        "www.popcap.com"
        "gameforge.com"
        "www.gameforge.com"

        # Humor, Memes & Distractions
        "9gag.com"
        "imgur.com"
        "boredpanda.com"
        "theonion.com"
        "www.theonion.com"
        "cracked.com"
        "www.cracked.com"
        "ebaumsworld.com"
        "www.ebaumsworld.com"
        "funnyordie.com"
        "www.funnyordie.com"
        "collegehumor.com"
        "www.collegehumor.com"

        # Forums & Infinite Scroll
        "4chan.org"
        "boards.4chan.org"
        "8kun.top"
        "slashdot.org"
        # "hackernews.com"
        # "news.ycombinator.com"
        # "medium.com"
        # "www.medium.com"
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
    # time.timeZone = "America/New_York";
    time.timeZone = "America/Denver";

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
    security = {
        rtkit.enable = true;
        apparmor.enable = true;
        auditd.enable = true;
        sudo.extraConfig = ''
            Defaults log_input,log_output
            Defaults timestamp_timeout=5
        '';
    };

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
        openssh = {
            enable = true;
            settings = {
                PasswordAuthentication = false;
                PermitRootLogin = "no";
            };
        };
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
        clamav = {
            daemon.enable = true;
            updater.enable = true;
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
            # uv
            # black
            alejandra
            clang-tools
            tree-sitter
            postman
            newman
            bruno-cli
            bruno
            # stripe-cli
            gibo
            textcompare
            licenseclassifier
            # jsonfmt
            # json2yaml
            # yamlfmt
            # yaml2json
            nasm
            nasmfmt
            asmrepl
            asmjit
            uasm
            gdb
            gdbgui
            libgcc
            # fbc
            # ncurses

            # Editors & IDEs
            neovim
            vscodium
            jetbrains.datagrip
            jetbrains.webstorm
            jetbrains.rust-rover
            jetbrains.rider
            jetbrains.pycharm-professional
            jetbrains.idea-ultimate
            jetbrains.goland
            jetbrains.clion

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
            # unixtools.quota
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
            wireguard-tools
            openvpn
            ipcalc
            nmap
            codecrafters-cli
            speedtest-cli
            rpi-imager
            opensnitch-ui
            whatfiles

            # Cloud CLI Utilities
            # awstats
            # linode-cli
            # doctl
            # azure-cli
            # google-cloud-sdk
            # aws-nuke
            awscli
            # awsls
            # awsume
            # awsbck
            # awslogs
            # aws-mfa
            # awsebcli
            # aws-gate
            # aws-shell
            # remmina
            # freerdp

            # Version Control
            git
            commitlint
            # jujutsu
            # lazyjj
            git-remote-gcrypt
            # glab
            # codeberg-cli
            gh
            github-desktop
            # gitbutler
            lazygit
            git-filter-repo
            delta
            # meld

            # Containerization & Deployment
            lazydocker
            # nix-init
            # stow
            unetbootin
            rclone

            # Browsers & Communication
            firefox
            # unstable.librewolf
            brave
            # chromium
            # unstable.ladybird
            # lynx
            signal-desktop
            # protonmail-bridge-gui
            proton-pass
            protonvpn-gui
            # protonvpn-cli
            # webcord
            zoom-us
            # thunderbird

            # Networking & Security
            openssl
            curl
            wget
            wireshark
            ethtool
            iw
            wirelesstools
            keepassxc

            # Media & Graphics
            alsa-utils
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
            # asciiquarium
            # aalib
            # oneko
            easyeffects
            playerctl
            pavucontrol
            imaginer

            # Office & Productivity
            libreoffice
            obsidian
            pomodoro-gtk
            # safeeyes
            pandoc
            texliveFull
            tectonic
            deskreen
            memorado
            varia
            blanket
            gnome-calculator
            letterpress
            sly
            kazam
            shotcut
            audacity
            peek
            cozy
            vlc
            handbrake
            libdvdcss

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
            font-awesome
            comic-mono
            catppuccin-cursors
            catppuccin-papirus-folders
            papirus-folders
            kdePackages.breeze-gtk
            kdePackages.breeze-icons
            kdePackages.breeze.qt5
            kdePackages.breeze

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
            # oh-my-git
            # learn6502

            # Miscellaneous
            # chance
            devtoolbox
            concessio
            #activitywatch
            ciano
            raider

            # Security
            firejail
            lynis
            chkrootkit
            gocryptfs
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
            # (lib.getBin qttools) # Expose qdbus in PATH
            # ark
            # elisa
            # gwenview
            # okular
            # kate
            khelpcenter
            # dolphin
            baloo-widgets # baloo information in Dolphin
            dolphin-plugins
            # spectacle
            ffmpegthumbs
            krdp
            # xwaylandvideobridge # exposes Wayland windows to X11 screen capture
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
                enableSSHSupport = false;
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

            # auto-update = {
            #     description = "Headless NixOS auto-update (battery, idle & load checks)";
            #     wants = ["network-online.target"];
            #     after = ["network-online.target"];
            #     serviceConfig = {
            #         Type = "simple";
            #         Environment = [
            #             "HOME=/home/nate"
            #             "PATH=/run/current-system/sw/bin:/home/nate/.local/bin"
            #         ];
            #         ExecStart = "${pkgs.bash}/bin/bash /home/nate/.local/bin/auto-update";
            #         Restart = "on-failure";
            #         RestartSec = 300;
            #         StandardOutput = "journal";
            #         StandardError = "journal";
            #     };
            # };

            # backup-github = {
            #     description = "Mirror all GitHub repos to GitLab + Proton Drive";
            #     wants = ["network-online.target"];
            #     after = ["network-online.target"];
            #     serviceConfig = {
            #         Type = "simple";
            #         Environment = [
            #             "HOME=/home/nate"
            #             "USER=nate"
            #             "PATH=/run/current-system/sw/bin:/home/nate/.local/bin"
            #         ];
            #         ExecStart = "${pkgs.bash}/bin/bash /home/nate/.local/bin/backup-github";
            #         Restart = "on-failure";
            #         RestartSec = 3600;
            #         StandardOutput = "journal";
            #         StandardError = "journal";
            #     };
            # };

            # sync-docs = {
            #     description = "Sync ~/Documents with Proton Drive via rclone bisync";
            #     wants = ["network-online.target"];
            #     after = ["network-online.target"];
            #     serviceConfig = {
            #         Type = "simple";
            #         Environment = [
            #             "HOME=/home/nate"
            #             "PATH=/run/current-system/sw/bin:/home/nate/.local/bin"
            #         ];
            #         ExecStart = "${pkgs.bash}/bin/bash /home/nate/.local/bin/sync-docs";
            #         Restart = "on-failure";
            #         RestartSec = 300;
            #         StandardOutput = "journal";
            #         StandardError = "journal";
            #     };
            # };

            # sync-audiobooks = {
            #     description = "Sync ~/Audiobooks with Proton Drive via rclone bisync";
            #     wants = ["network-online.target"];
            #     after = ["network-online.target"];
            #     serviceConfig = {
            #         Type = "simple";
            #         Environment = [
            #             "HOME=/home/nate"
            #             "PATH=/run/current-system/sw/bin:/home/nate/.local/bin"
            #         ];
            #         ExecStart = "${pkgs.bash}/bin/bash /home/nate/.local/bin/sync-audiobooks";
            #         Restart = "on-failure";
            #         RestartSec = 300;
            #         StandardOutput = "journal";
            #         StandardError = "journal";
            #     };
            # };

            # sync-music = {
            #     description = "Sync ~/Music with Proton Drive via rclone bisync";
            #     wants = ["network-online.target"];
            #     after = ["network-online.target"];
            #     serviceConfig = {
            #         Type = "simple";
            #         Environment = [
            #             "HOME=/home/nate"
            #             "PATH=/run/current-system/sw/bin:/home/nate/.local/bin"
            #         ];
            #         ExecStart = "${pkgs.bash}/bin/bash /home/nate/.local/bin/sync-music";
            #         Restart = "on-failure";
            #         RestartSec = 300;
            #         StandardOutput = "journal";
            #         StandardError = "journal";
            #     };
            # };

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
            # auto-update = {
            #     description = "Headless NixOS auto-update (battery, idle & load checks)";
            #     wantedBy = ["timers.target"];
            #     timerConfig = {
            #         OnCalendar = "daily";
            #         Persistent = true;
            #     };
            # };

            # backup-github = {
            #     description = "Headless mirror of GitHub repos to GitLab + Proton Drive";
            #     wantedBy = ["timers.target"];
            #     timerConfig = {
            #         OnCalendar = "weekly";
            #         Persistent = true;
            #     };
            # };

            # sync-docs = {
            #     description = "Hourly trigger for sync-docs.service";
            #     wantedBy = ["timers.target"];
            #     timerConfig = {
            #         OnCalendar = "hourly";
            #         Persistent = true;
            #     };
            # };

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
