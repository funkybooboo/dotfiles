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
in {
    # System
    system = {
        stateVersion = "25.05"; # see https://ostechnix.com/upgrade-nixos/
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

    # Bootloader
    boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
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

    # Services
    services = {
        systembus-notify.enable = true;
        locate.enable = true;
        fwupd.enable = true;
        printing.enable = true;
        openssh.enable = true;
        pulseaudio.enable = false;
        pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
        };
        mysql = {
            enable = true;
            package = pkgs.mariadb;
            initialScript = toString mysqlInitScript;
        };
        xserver = {
            enable = true;
            xkb = {
                layout = "us";
                variant = "";
            };
        };
        libinput.enable = true;
        displayManager = {
            sddm = {
                enable = true;
                wayland.enable = true;
            };
            defaultSession = "plasma";
        };
        desktopManager.plasma6.enable = true;
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

            # Version Control
            git
            gh
            github-desktop
            lazygit
            git-filter-repo
            gitbutler

            # Containerization & Deployment
            lazydocker
            nix-init
            stow
            unetbootin
            rclone

            # Browsers & Communication
            firefox
            librewolf
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
            wireplumber

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
            # plasma-browser-integration
            # konsole
            # khelpcenter
            # baloo-widgets
            # ffmpegthumbs
            # krdp
        ];
    };

    xdg.portal = {
        enable = true;
        extraPortals = [
            pkgs.xdg-desktop-portal
            pkgs.xdg-desktop-portal-gtk
            pkgs.xdg-desktop-portal-hyprland
        ];
    };

    # Programs
    programs = {
        fish = {
            enable = true;
        };
        neovim = {
            enable = true;
            viAlias = true;
            vimAlias = true;
        };
        mtr = {
            enable = true;
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
            nerd-fonts.fira-code
            nerd-fonts.droid-sans-mono
            nerd-fonts.jetbrains-mono
        ];
        fontconfig = {
            useEmbeddedBitmaps = true;
        };
    };
}
