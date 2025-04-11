{
  config,
  pkgs,
  ...
}: let
  unstableTarball =
    fetchTarball
    https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
in {
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
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

  # Display Manager
  services.libinput.enable = true;
  services.xserver.displayManager.lightdm.enable = true;

  # Desktop Environment
  services.xserver.desktopManager.cinnamon.enable = true;
  environment.cinnamon.excludePackages = with pkgs; [
    nemo
    xfce.xfce4-terminal
    gnome-terminal
    xed
    xterm
    baobab
    epiphany
    evince
    geary
    gnome-calculator
    gnome-contacts
    gnome-logs
    gnome-maps
    gnome-music
    gnome-screenshot
    gnome-system-monitor
    pkgs.gnome-connections
    pkgs.gnome-console
  ];

  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;

  services.displayManager.defaultSession = "hyprland";

  # Enable CUPS to print documents
  services.printing.enable = true;

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
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

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.variables = {
    EDITOR = "nvim";
  };

  fonts.packages = with pkgs; [nerdfonts];
  fonts.fontconfig.useEmbeddedBitmaps = true;

  # Define a user account. Don't forget to set a password with ‘passwd’
  users.users.nate = {
    isNormalUser = true;
    description = "Nate Stott";
    extraGroups = ["networkmanager" "wheel" "wireshark" "docker"];
    shell = pkgs.fish;
    packages = with pkgs; [
      neovim # Highly extensible text editor for coding
      tree-sitter # Parser generator for syntax highlighting and code analysis
      lazygit # Simple terminal UI for git commands
      luajitPackages.luarocks-nix # LuaJIT support for LuaRocks package manager
      fd # Fast and user-friendly alternative to 'find'
      lsof
      go # Go programming language
      fish # User-friendly command-line shell
      kitty # Fast, feature-rich, GPU-based terminal emulator
      webcord
      cloc # Counts lines of code in programming projects
      lsd # Modern alternative to 'ls' with better formatting
      bat # 'cat' command with syntax highlighting and Git integration
      tldr # Simplified and community-contributed man pages
      unstable.wikiman # Wiki-based markdown documentation viewer
      fzf # Command-line fuzzy finder
      wireshark # Network protocol analyzer
      zoom-us # Video conferencing tool
      alpaca # Simple CLI for working with large codebases
      obsidian # Knowledge management and note-taking application
      blanket # Minimalistic note-taking app for programmers
      drawio # Diagramming tool for creating flowcharts and UML diagrams
      lazydocker # Terminal UI for managing Docker containers
      proton-pass # Password manager integrated with Proton services
      # protonmail-desktop # Desktop client for ProtonMail secure email
      protonmail-bridge-gui # GUI for ProtonMail Bridge, integrates ProtonMail with email clients
      protonvpn-gui # GUI for ProtonVPN for secure internet connections
      yazi # TUI file viewer
      timg # Image viewer for the terminal
      asciinema # Record and share terminal sessions
      # aalib # ASCII art library for image and video rendering
      # oneko # Classic Japanese cat chasing a mouse on the screen
      espeak # Compact open-source software speech synthesizer
      asciiquarium # Fun aquarium screensaver in ASCII art
      nix-tour # Educational tour through Nix and NixOS
      lynx # Text-based web browser
      gh # GitHub CLI tool for managing GitHub repositories
      vscodium
      # pomodoro-gtk # Pomodoro technique timer for productivity
      jq # Command-line JSON processor
      unetbootin # Tool for creating bootable USB drives
      deskreen # Share your desktop to any device over the network
      rclone # Command-line program for managing cloud storage
      rclone-browser # GUI for managing cloud storage with Rclone
      signal-desktop # Secure messaging app for desktop
      pandoc # Universal document converter
      texliveTeTeX # TeXLive distribution for typesetting documents
      unixtools.xxd # Hexdump tool for examining binary files
      black # Python code formatter
      sbcl # Steel Bank Common Lisp compiler
      gfortran # GNU Fortran compiler for compiling Fortran programs.
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
      xfce.thunar
      gparted

      tor-browser
      deluge
      dumptorrent
      buildtorrent

      safeeyes

      jetbrains.datagrip
      jetbrains.webstorm # JetBrains IDE for JavaScript and web development
      jetbrains.rust-rover # JetBrains IDE for Rust development
      jetbrains.rider # JetBrains IDE for .NET development
      jetbrains.pycharm-professional # Professional IDE for Python development
      jetbrains.idea-ultimate # Ultimate edition of JetBrains IntelliJ IDEA, for Java, Kotlin, and other languages
      jetbrains.goland # JetBrains IDE for Go programming language
      jetbrains.clion # JetBrains IDE for C and C++ development
    ];
  };

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = ["nate"];
  virtualisation.virtualbox.host.enableExtensionPack = true;
  virtualisation.virtualbox.guest.enable = true;
  virtualisation.virtualbox.guest.dragAndDrop = true;

  virtualisation.docker.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

  environment.systemPackages = with pkgs; [
    # os building tools
    qemu
    imhex
    open-watcom-v2
    grub2
    libisoburn
    bison
    flex
    gmp
    libmpc
    mpfr
    texinfo

    libreoffice # Full-featured open-source office suite
    vim # Highly configurable text editor
    wget # Command-line utility for downloading files from the web
    curl # Command-line tool for transferring data with URLs
    firefox
    librewolf
    ladybird
    brave
    chromium # Open-source version of the Chrome web browser
    git # Distributed version control system
    gnat14 # GNAT compiler for Ada and other languages
    libgcc # GCC runtime library for C and C++ programs
    gdb # GNU Debugger for debugging applications
    gdbgui # Web-based interface for GDB
    zig # Programming language for general-purpose programming
    rustlings
    rustup
    rustfmt # Rust code formatter
    fnm # Fast Node Manager for managing Node.js versions
    typescript # JavaScript superset for adding static types
    deno # Secure runtime for JavaScript and TypeScript
    dbeaver-bin # Universal database tool for developers
    bruno-cli # Command-line interface for managing databases with Bruno
    bruno # Open-source database client and management tool
    clang-tools # Tools for working with Clang compiler and LLVM
    python313 # Python 3.13 interpreter
    python312Packages.pip # Python package installer for Python 3.12
    php # PHP programming language interpreter
    php84Packages.composer # Dependency manager for PHP 8.4
    poetry # Python dependency manager and packaging tool
    zulu23 # OpenJDK 23 distribution from Azul
    gradle # Build automation system for Java projects
    cmake # Build system and compiler configuration tool
    gnumake # GNU version of the 'make' utility
    alejandra # JSON and YAML configuration parser for Haskell
    zip # Compression and file packaging utility
    unzip # Utility for extracting compressed ZIP files
    tmux # Terminal multiplexer for managing multiple terminal sessions
    sqlite # Lightweight relational database management system
    tree # Command-line utility for displaying directory trees
    htop-vim # Interactive process viewer with Vim-like keybindings
    fastfetch # A simple and fast system information tool
    lua51Packages.lua # Lua programming language interpreter (version 5.1)
    julia # High-level, high-performance dynamic programming language for technical computing
    batmon # Battery monitor for Linux
    xclip # Command-line interface to the X11 clipboard
    ripgrep # Fast text searching tool
    dotnetCorePackages.sdk_9_0 # .NET Core SDK for building cross-platform applications
    ffmpeg # Command-line tool for handling multimedia files
    nasm # Netwide Assembler, a popular assembler for x86 architectures
    nasmfmt # Formatter for NASM source code
    asmrepl # Interactive REPL for assembly language
    asmjit # Library for machine code generation in assembly language
    uasm # UASM assembler for x86 and x64 architectures
    gnupg # GNU Privacy Guard for secure communication and file encryption
    nix-init # NixOS system initialization tool
    stow # Sym-link manager

    kdePackages.breeze-gtk
    kdePackages.breeze-icons
    kdePackages.breeze.qt5
    kdePackages.breeze
    catppuccin-cursors # Mouse cursor theme
    catppuccin-papirus-folders # Icon theme, e.g. for pcmanfm-qt
    papirus-folders # For the catppucing stuff work

    font-awesome

    # hyprland software
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
    libnotify # Library for sending desktop notifications
    ianny
    easyeffects
    hyprpolkitagent
    hypridle
    brightnessctl
    hyprlock
    nwg-look
    wireplumber

    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    libsForQt5.xwaylandvideobridge

    cliphist
    wlogout
    hyprshot

    ethtool
    wirelesstools
    iw
    bc

    sysstat
  ];

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

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
