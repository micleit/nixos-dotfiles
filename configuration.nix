
{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      ./hostname.nix
      /etc/nixos/hardware-configuration.nix
      ./modules/kanata.nix
      ./modules/fish.nix
    ];

  boot.supportedFilesystems = ["fuse"];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


  

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

  services.displayManager.ly.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  hardware.nvidia.modesetting.enable = true;
  hardware.graphics.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

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

  environment.systemPackages = with pkgs; [
    vim 
    wget
    librewolf
    git
    alacritty
    # open-vm-tools
    foot
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
  ];
  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
	nerd-fonts.jetbrains-mono
  ];
 
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.11"; 

}

