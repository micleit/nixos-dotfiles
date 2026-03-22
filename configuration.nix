
{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ 
      ./hostname.nix
      /etc/nixos/hardware-configuration.nix
      ./modules/fish.nix
    ];

  boot.supportedFilesystems = ["fuse"];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

  boot.loader.systemd-boot.consoleMode = "1";

  boot.plymouth = {
  enable = true;
  theme = "breeze"; 
};

  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
  ];


  

  networking.networkmanager.enable = true;
  networking.nameservers = ["1.1.1.1" "8.8.8.8"];
  services.openssh.enable = true;
  services.tailscale.enable = true;

#immich setup
  # services.immich = {
  #   enable = true;
  #   host = "0.0.0.0";
  #   port = 2283;
  #   mediaLocation = "/var/lib/immich";
  # };
  # services.immich.openFirewall = true;
  # users.users.immich.extraGroups = [ "users" ];

  # Set your time zone.
  time.timeZone = "America/New_York";


  services.displayManager.sddm.wayland.enable = true;
  services.greetd.enable = true;
  programs.regreet = {
    enable = true;
    
    # Theme settings (Ensure these match your installed packages)
    settings = {
      background = {
        path = "home/mic/nixos-dotfiles/walls/wall1.png"; # Change to your path
        fit = "Cover";
      };
      GTK = {
        theme_name = "Gruvbox-Retro";
        icon_theme_name = "Gruvbox-Dark";
        font_name = "Lexend 12";
        cursor_theme_name = "Capitaine-Cursors-Gruvbox";
      };
    };
  };

  services.displayManager.sessionPackages = [ pkgs.hyprland ];


  # services.displayManager.ly.enable = true;
# services.displayManager.ly.settings = {
#   fg = 6;            # 3 is typically Yellow/Gold in terminal palettes
#   bg = 0;            # 0 is Black/Background
#   margin = 2;
#   input_len = 20;
#   bigclock = true;
#   clock = "%H:%M:%S";
#   animation = 2; # 1 = PSX-style fire, 2 = Matrix
# };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QUICKSHELL_PLUGIN_PATH = "${inputs.noctalia-qs.packages.${pkgs.system}.default}/lib/quickshell/plugins";
  };

  services.tuned.enable = true;
  services.upower.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  environment.etc = {
    "resolv.conf".text = "nameserver 1.1.1.1\n";
  };

  # auto mounts new disks
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  users.users.mic = {
    isNormalUser = true;
    extraGroups = [ "wheel" "optical" "storage" "cdrom"]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };
  hardware.parallels.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.polkit.enable = true;


  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this:
    # jack.enable = true;
  };


  environment.systemPackages = with pkgs; [
    vim 
    wget
    librewolf
    git
    alacritty
    # open-vm-tools
    wmenu
    wl-clipboard
    grim
    slurp
    swaybg
    gtk3
    xwayland-satellite
    ffmpeg
    unzip
    # brasero
    vlc
    # cdrdao
    quickshell
    pavucontrol # audio gui
    wireplumber # audio things
    mangohud # monitor fps
    geary #email
    seahorse
    adi1090x-plymouth-themes
    gruvbox-gtk-theme
    capitaine-cursors-themed
    lexend
    cage # ReGreet needs this to run as a Wayland compositor
  ];
  nixpkgs.config.allowUnfree = true;

  #GAMING THINGS
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;

  fonts.packages = with pkgs; [
	nerd-fonts.jetbrains-mono
  ];
 
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.11"; 

}

