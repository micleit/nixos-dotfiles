
{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-btw"; # Define your hostname.
  virtualisation.vmware.guest.enable = true;
  hardware.graphics.enable = true;
  hardware.opengl.enable = true;

  networking.networkmanager.enable = true;
  networking.nameservers = ["1.1.1.1" "8.8.8.8"];

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  services.xserver = {
	enable = true;
	autoRepeatDelay = 200;
	autoRepeatInterval = 35;
	windowManager.qtile.enable = true;
  };
  services.displayManager.ly.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  environment.etc = {
    "resolv.conf".text = "nameserver 1.1.1.1\n";
  };


  

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mic = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    vim 
    wget
    git
    alacritty
    kitty
    open-vm-tools
    foot
    wmenu
    wl-clipboard
    grim
    slurp
    swaybg
    firefox
    keyd
    gtk4
    xwayland
  ];


  fonts.packages = with pkgs; [
	nerd-fonts.jetbrains-mono
  ];
 
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.11"; 

}

