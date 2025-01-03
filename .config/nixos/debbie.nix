# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: let
  # add unstable channel declaratively
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

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
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

  # Configure X11
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  services.libinput.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;
  services.xserver.displayManager.lightdm.enable = true;

  services.displayManager.defaultSession = "cinnamon";

  environment.cinnamon.excludePackages = with pkgs; [
  ];

  programs.hyprland.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  programs.fish.enable = true;

  environment.variables.EDITOR = "nvim";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nate = {
    isNormalUser = true;
    description = "Nate Stott";
    extraGroups = ["networkmanager" "wheel" "wireshark"];
    shell = pkgs.fish;
    packages = with pkgs; [
      neovim
      tree-sitter
      lazygit
      luajitPackages.luarocks-nix
      fd
      go
      fish
      kitty
      discord
      cloc
      lsd
      bat
      tldr
      unstable.wikiman
      fzf
      docker
      wireshark
      postman
      zoom-us
      alpaca
      obsidian
      chromium
      blanket
      drawio
      drawing
      musicpod
      vlc
      ladybird
      lazygit
      lazydocker
      proton-pass
      protonmail-desktop
      protonmail-bridge-gui
      protonvpn-gui
      discordo
      yazi
      timg
      asciinema
      cmatrix
      aalib
      oneko
      espeak
      asciiquarium
      nix-tour
      lynx
      gh
      todo
      vscode
      pomodoro-gtk
      jq
      unetbootin
      deskreen
      rclone
      rclone-browser
      signal-desktop
      faircamp
      pandoc
      texliveTeTeX

      jetbrains.webstorm
      jetbrains.rust-rover
      jetbrains.rider
      jetbrains.pycharm-professional
      jetbrains.idea-ultimate
      jetbrains.goland
      jetbrains.clion
    ];
  };

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = ["nate"];
  virtualisation.virtualbox.host.enableExtensionPack = true;
  virtualisation.virtualbox.guest.enable = true;
  virtualisation.virtualbox.guest.dragAndDrop = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    libreoffice
    vim
    wget
    curl
    firefox
    git
    gnat14
    libgcc
    gdb
    gdbgui
    zig
    cargo
    rustc
    rustfmt
    fnm
    typescript
    deno
    dbeaver-bin
    bruno-cli
    bruno
    clang-tools
    python313
    python312Packages.pip
    python312Packages.meson
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
    nerdfonts
    dotnetCorePackages.sdk_9_0
    libnotify
    ffmpeg
    nasm
    nasmfmt
    asmrepl
    asmjit
    uasm
    gnupg
    nix-init

    wofi
  ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

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
      "-L"
    ];
    dates = "9:00";
    randomizedDelaySec = "45min";
  };
}
