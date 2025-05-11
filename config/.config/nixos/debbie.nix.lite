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
  };

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
#    elisa
#    gwenview
#    okular
#    kate
    khelpcenter
#    dolphin
    baloo-widgets
#    dolphin-plugins
    ffmpegthumbs
    krdp
  ];

  services.displayManager.defaultSession = "plasma";

  # Enable CUPS to print documents
  services.printing.enable = true;

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

#  security.sudo.enable = true;

  environment.variables = {
    EDITOR = "vim";
  };

  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [nerdfonts];
  fonts.fontconfig.useEmbeddedBitmaps = true;

  # Define a user account. Don't forget to set a password with ‘passwd’
  users.users.nate = {
    isNormalUser = true;
    description = "Nate Stott";
    extraGroups = ["networkmanager" "wheel" "wireshark" "docker"];
    shell = pkgs.bash;
  };

  environment.systemPackages = with pkgs; [
    fd # Fast and user-friendly alternative to 'find'
    lsof
    fish # User-friendly command-line shell
    kitty # Fast, feature-rich, GPU-based terminal emulator
    lsd # Modern alternative to 'ls' with better formatting
    tldr # Simplified and community-contributed man pages
    fzf # Command-line fuzzy finder
    blanket # Minimalistic note-taking app for programmers
    unetbootin # Tool for creating bootable USB drives
    poppler_utils
    file
    zoxide
    jump
    ripgrep
    imagemagick
    zathura

    libstdcxx5

    libreoffice # Full-featured open-source office suite
    wget # Command-line utility for downloading files from the web
    curl # Command-line tool for transferring data with URLs
    firefox
    git # Distributed version control system
    gnat14 # GNAT compiler for Ada and other languages
    libgcc # GCC runtime library for C and C++ programs
    alejandra # JSON and YAML configuration parser for Haskell
    zip # Compression and file packaging utility
    unzip # Utility for extracting compressed ZIP files
    tree # Command-line utility for displaying directory trees
    htop-vim # Interactive process viewer with Vim-like keybindings
    fastfetch # A simple and fast system information tool
    stow # Sym-link manager

    unixtools.quota
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
