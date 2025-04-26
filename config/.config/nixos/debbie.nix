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
    "dev.zelikos.rollit"
    "io.github.voxelcubes.hand-tex"
    "io.github.dman95.SASM"
    "io.github.hamza_algohary.Coulomb"
    "io.gitlab.persiangolf.voicegen"
    "com.play0ad.zeroad"
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
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

  system.activationScripts.installFlatpaks = ''
    if command -v flatpak >/dev/null; then
      if ! flatpak remote-list | grep -q flathub; then
        flatpak remote-add flathub https://flathub.org/repo/flathub.flatpakrepo
      fi

      for app in ${flatpakAppList}; do
        flatpak install -y --noninteractive flathub "$app" || true
      done
    else
      echo "Flatpak not available during activation, skipping install."
    fi
  '';

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone
  time.timeZone = "America/New_York";
  #time.timeZone = "America/Denver";

  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
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

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Configure X11
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  services.libinput.enable = true;

  # Display Manager
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    konsole
    elisa
    gwenview
    okular
    kate
    khelpcenter
    dolphin
    baloo-widgets
    dolphin-plugins
    ffmpegthumbs
    krdp
  ];

  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;

  services.displayManager.defaultSession = "plasma";

  # Enable CUPS to print documents
  services.printing.enable = true;

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    initialScript = toString mysqlInitScript;
  };

  # Enable sound with pipewire
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  programs.fish.enable = true;

  services.systembus-notify.enable = true;

  services.flatpak.enable = true;

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-kde
      pkgs.xdg-desktop-portal-hyprland
    ];
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.variables = {
    EDITOR = "nvim";
  };

  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [nerdfonts];
  fonts.fontconfig.useEmbeddedBitmaps = true;

  # Define a user account. Don't forget to set a password with ‘passwd’
  users.users.nate = {
    isNormalUser = true;
    description = "Nate Stott";
    extraGroups = ["networkmanager" "wheel" "wireshark" "docker"];
    shell = pkgs.fish;
  };

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = ["nate"];
  virtualisation.virtualbox.host.enableExtensionPack = true;
  virtualisation.virtualbox.guest.enable = true;
  virtualisation.virtualbox.guest.dragAndDrop = true;

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    # ─── Programming Languages ───
    go
    julia
    lua51Packages.lua
    php
    python313
    python312Packages.pip
    rustup
    sbcl
    zulu23
    dotnetCorePackages.sdk_9_0

    # ─── Compilers, Build Systems, and Low-Level Tools ───
    asmjit
    asmrepl
    bison
    cmake
    flex
    gfortran
    gmp
    gnat14
    gradle
    maven
    gnumake
    imhex
    libmpc
    mpfr
    nasm
    nasmfmt
    open-watcom-v2
    texinfo
    uasm
    gdb
    gdbgui

    # ─── Development Tools ───
    alejandra
    bat
    cloc
    fastfetch
    fd
    fzf
    gh
    git
    gitbutler
    git-filter-repo
    glow
    jq
    lazygit
    lsd
    neovim
    ripgrep
    stow
    tree
    unixtools.xxd
    yq
    fnm
    typescript
    deno
    poetry
    black
    bruno
    bruno-cli
    rustfmt
    rustlings

    # ─── IDES ───
    jetbrains.clion
    jetbrains.datagrip
    jetbrains.goland
    jetbrains.idea-ultimate
    jetbrains.pycharm-professional
    jetbrains.rider
    jetbrains.rust-rover
    jetbrains.webstorm
    vscodium

    # ─── Database Tools ───
    dbeaver-bin
    sqlite

    # ─── Operating System Building and Virtualization ───
    grub2
    libisoburn
    qemu

    # ─── Nix/NixOS Tools ───
    nix-init
    nix-tour

    # ─── System Utilities ───
    bc
    curl
    file
    htop-vim
    imagemagick
    ripgrep
    safeeyes
    stow
    wget
    xclip
    zip
    unzip
    gparted

    # ─── Browsers ───
    brave
    chromium
    firefox
    ladybird
    librewolf
    lynx
    tor-browser

    # ─── Communication ───
    signal-desktop
    webcord
    zoom-us
    thunderbird

    # ─── VPN / Security ───
    proton-pass
    protonmail-bridge-gui
    protonvpn-gui

    # ─── Cloud Storage / Backup Tools ───
    deskreen
    rclone
    rclone-browser

    # ─── Office and Productivity ───
    blanket
    drawio
    libreoffice
    obsidian

    # ─── Multimedia Tools ───
    asciinema
    mpv
    pandoc
    poppler_utils
    texliveTeTeX
    timg
    zathura
    ffmpeg

    # ─── Fun / Educational ───
    asciiquarium
    chess-tui
    espeak
    stockfish
    aalib
    oneko

    # ─── File Sharing / Torrenting ───
    buildtorrent
    deluge
    dumptorrent
    unetbootin

    # ─── Docker / Containers ───
    docker-compose
    lazydocker

    # ─── Hyprland / Wayland Ecosystem ───
    brightnessctl
    cliphist
    easyeffects
    hypridle
    hyprlock
    hyprpaper
    hyprpicker
    hyprpolkitagent
    hyprshot
    hyprsunset
    hyprlandPlugins.hyprbars
    hyprlandPlugins.hyprexpo
    libnotify
    libsForQt5.xwaylandvideobridge
    networkmanagerapplet
    nwg-look
    pavucontrol
    playerctl
    power-profiles-daemon
    swaynotificationcenter
    waybar
    wireplumber
    wlogout
    wofi
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-kde
    xdg-desktop-portal-hyprland

    # ─── KDE and Themes ───
    catppuccin-cursors
    catppuccin-papirus-folders
    font-awesome
    kdePackages.breeze
    kdePackages.breeze-gtk
    kdePackages.breeze-icons
    kdePackages.breeze.qt5
    papirus-folders

    # ─── Miscellaneous Utilities ───
    alpaca
    concessio
    devtoolbox
    imaginer
    keypunch
    memorado
    varia
    unstable.wikiman
  ];

  services.locate.enable = true;

  programs.neovim.enable = true;
  programs.neovim.viAlias = true;
  programs.neovim.vimAlias = true;

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [];
  networking.firewall.allowedUDPPorts = [];

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs here, NOT in environment.systemPackages
  ];

  systemd.services.flatpak-update = {
    description = "Update all Flatpak apps";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.flatpak}/bin/flatpak update --noninteractive";
      StandardOutput = "append:/var/log/flatpak-update.log";
      StandardError = "append:/var/log/flatpak-update.log";
    };
  };

  systemd.timers.flatpak-update = {
    description = "Run daily Flatpak updates";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11";

  system.autoUpgrade = {
    enable = true;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L" # print build logs
    ];
    dates = "2:00";
    randomizedDelaySec = "45min";
  };
}
