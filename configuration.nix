{ config, lib, pkgs, inputs, ... }:

{
  imports = [ 
    ./hostname.nix
    /etc/nixos/hardware-configuration.nix
    ./modules/fish.nix
  ];

  # ============================================================================
  # BOOT & KERNEL
  # ============================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "1";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "fuse" ];
  
  # Silent Boot / Plymouth
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.plymouth = {
    enable = true;
    theme = "breeze"; 
  };

  boot.kernelParams = [
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
  ];

  # ============================================================================
  # NETWORKING & SERVICES
  # ============================================================================
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
  
  services.openssh.enable = true;
  services.tailscale.enable = true;
  services.tuned.enable = true;
  services.upower.enable = true;
  
  # Time & Locale
  time.timeZone = "America/New_York";
  services.timesyncd.enable = true;

  # Mounting / Storage Services
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # ============================================================================
  # IMMICH SETUP (Uncomment to enable on specific machines)
  # ============================================================================
  # services.immich = {
  #   enable = true;
  #   host = "0.0.0.0";
  #   port = 2283;
  #   mediaLocation = "/var/lib/immich";
  #   openFirewall = true;
  # };
  # users.users.immich.extraGroups = [ "users" ];

  # ============================================================================
  # GRAPHICS & HYPRLAND
  # ============================================================================
  services.xserver.videoDrivers = [ "nvidia" ];
  
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = false; # Set to true for 1660 Super if using Open modules, but false is safer for stable
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Display Manager (SDDM for Wayland, Ly as fallback/TUI)
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.ly.enable = true;

  # ============================================================================
  # AUDIO (Pipewire)
  # ============================================================================
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ============================================================================
  # USER & SECURITY
  # ============================================================================
  users.users.mic = {
    isNormalUser = true;
    extraGroups = [ "wheel" "optical" "storage" "cdrom" ];
    packages = with pkgs; [ tree ];
  };

  security.sudo.extraConfig = "Defaults pwfeedback";
  security.polkit.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;

  # ============================================================================
  # SYSTEM PACKAGES
  # ============================================================================
  environment.systemPackages = with pkgs; [
    # Core
    vim wget git librewolf alacritty 
    
    # Utilities
    jq unzip ffmpeg wl-clipboard wmenu mpvpaper
    
    # Desktop / Media
    vlc geary seahorse pavucontrol wireplumber
    
    # Hyprland / Wayland Tools
    quickshell hyprpolkitagent xwayland-satellite
    grim slurp swaybg gtk3 hyprshot
    
    # Theming / Cursors
    apple-cursor
    adi1090x-plymouth-themes
    lua-language-server          # For lua_ls
  basedpyright                 # For Python (better than standard pyright)
  nodePackages.typescript-language-server # For ts_ls
  vscode-langservers-extracted # For html, css, json, eslint
  texlab                       # For LaTeX (better LSP than just Vimtex)
  nil                          # High-performance Nix LSP
  stylua                       # Lua formatting
  black                        # Python formatting
  nodePackages.prettier        # HTML/JS/TS formatting
  gcc
  gnumake
  curl
  tree-sitter
  zathura             # The viewer
  texliveFull         # Includes pdflatex, bibtex, and latexmk
  xdotool
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QUICKSHELL_PLUGIN_PATH = "${inputs.noctalia-qs.packages.${pkgs.system}.default}/lib/quickshell/plugins";
  };


  # Set Neovim as the system-wide default editor
  programs.neovim = {
    enable = true;
    defaultEditor = true; # This sets $EDITOR to nvim automatically
    viAlias = true;       # Optional: types 'vi' opens nvim
    vimAlias = true;      # Optional: types 'vim' opens nvim
  };

  programs.yazi.enable = true;

  # ============================================================================
  # GAMING & FONTS
  # ============================================================================
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;
  programs.localsend.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # ============================================================================
  # NIX SETTINGS
  # ============================================================================
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Compatibility / Drivers
  # hardware.parallels.enable = true;

  system.stateVersion = "25.11"; 
}
