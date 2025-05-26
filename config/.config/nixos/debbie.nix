{
  config,
  pkgs,
  lib,
  ...
}: let
  unstableTarball = fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
  };
  flatpakApps = [
    "io.github.voxelcubes.hand-tex"
    "io.github.dman95.SASM"
    "io.gitlab.persiangolf.voicegen"
  ];
  flatpakAppList = lib.concatStringsSep " " flatpakApps;

  mysqlInitScript = pkgs.writeTextFile {
    name = "mariadb-init";
    text = lib.concatStringsSep "\n" [
      "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';"
      "FLUSH PRIVILEGES;"
    ];
  };
in {
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

  # Bootloader
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Security
  security.rtkit.enable = true;

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

  # Environment
  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
    variables = {
      EDITOR = "nvim";
    };
    plasma6.excludePackages = with pkgs.kdePackages; [
      plasma-browser-integration
      konsole
      khelpcenter
      baloo-widgets
      ffmpegthumbs
      krdp
    ];
    systemPackages = with pkgs; [
      flatpak
      viewnior
      maven
      neovim
      tree-sitter
      lazygit
      luajitPackages.luarocks-nix
      fd
      lsof
      go
      fish
      kitty
      webcord
      cloc
      lsd
      bat
      tldr
      wikiman
      fzf
      wireshark
      zoom-us
      alpaca
      imaginer
      chance
      memorado
      varia
      keypunch
      devtoolbox
      concessio
      obsidian
      blanket
      drawio
      lazydocker
      proton-pass
      protonmail-bridge-gui
      protonvpn-gui
      openssl
      yazi
      timg
      asciinema
      aalib
      oneko
      espeak
      asciiquarium
      nix-tour
      lynx
      gh
      github-desktop
      vscodium
      pomodoro-gtk
      jq
      yq
      unetbootin
      deskreen
      rclone
      rclone-browser
      signal-desktop
      pandoc
      texliveTeTeX
      unixtools.xxd
      black
      sbcl
      gfortran
      git-filter-repo
      ascii
      mpv
      glow
      chess-tui
      stockfish
      poppler_utils
      file
      zoxide
      jump
      ripgrep
      imagemagick
      zathura
      gparted

      gitbutler
      stripe-cli

      unstable.jetbrains.datagrip
      unstable.jetbrains.webstorm
      unstable.jetbrains.rust-rover
      unstable.jetbrains.rider
      unstable.jetbrains.pycharm-professional
      unstable.jetbrains.idea-ultimate
      unstable.jetbrains.goland
      unstable.jetbrains.clion

      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland

      libreoffice
      vim
      wget
      curl
      firefox
      librewolf
      brave
      chromium
      git
      gnat14
      libgcc
      gdb
      gdbgui
      zig
      rustlings
      rustup
      rustfmt
      fnm
      typescript
      deno
      dbeaver-bin
      bruno-cli
      bruno
      postman
      newman
      clang-tools
      python313
      python312Packages.pip
      php
      php84Packages.composer
      poetry
      zulu23
      gradle
      cmake
      gnumake
      alejandra
      zip
      unzip
      tmux
      sqlite
      tree
      htop-vim
      fastfetch
      lua51Packages.lua
      julia
      batmon
      xclip
      ripgrep
      dotnetCorePackages.sdk_9_0
      ffmpeg
      nasm
      nasmfmt
      asmrepl
      asmjit
      uasm
      nix-init
      stow
      unixtools.quota
      thunderbird

      kdePackages.breeze-gtk
      kdePackages.breeze-icons
      kdePackages.breeze.qt5
      kdePackages.breeze
      catppuccin-cursors
      catppuccin-papirus-folders
      papirus-folders
      font-awesome

      wofi
      hyprsunset
      waybar
      pavucontrol
      playerctl
      hyprpaper
      hyprpicker
      hyprlandPlugins.hyprbars
      hyprlandPlugins.hyprexpo
      networkmanagerapplet
      power-profiles-daemon
      swaynotificationcenter
      libnotify
      easyeffects
      hyprpolkitagent
      hypridle
      brightnessctl
      hyprlock
      nwg-look
      wireplumber
      libsForQt5.xwaylandvideobridge
      cliphist
      wlogout
      hyprshot
      ethtool
      wirelesstools
      iw
      bc
      sysstat

      unstable.jami
      kondo
      wiper
    ];
  };

  # Program
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
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
  };

  # Services
  services = {
    systembus-notify.enable = true;
    flatpak.enable = true;
    locate.enable = true;
    fwupd.enable = true;
    blueman.enable = true;
    printing.enable = true;
    pulseaudio.enable = false;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
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

  # Systemd
  systemd = {
    services = {
      install-flatpaks = {
        description = "Install Flatpak apps from Flathub";
        wantedBy = ["multi-user.target"];
        after = ["flatpak-system-helper.service"];
        serviceConfig = {
          Type = "oneshot";
          # Inject PATH so flatpak is found
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
          StandardOutput = "append:/var/log/install-flatpaks.log";
          StandardError = "append:/var/log/install-flatpaks.log";
        };
      };

      flatpak-update = {
        description = "Update all Flatpak apps";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.flatpak}/bin/flatpak update --noninteractive";
          StandardOutput = "append:/var/log/flatpak-update.log";
          StandardError = "append:/var/log/flatpak-update.log";
        };
      };
    };

    timers = {
      flatpak-update = {
        description = "Run daily Flatpak updates";
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
        };
      };
    };
  };

  # System
  system = {
    stateVersion = "25.05"; # see https://ostechnix.com/upgrade-nixos/
    autoUpgrade = {
      enable = true;
      flags = [
        "--update-input"
        "nixpkgs"
        "-L" # print build logs
      ];
      dates = "2:00";
      randomizedDelaySec = "45min";
      allowReboot = true;
    };
  };
}
