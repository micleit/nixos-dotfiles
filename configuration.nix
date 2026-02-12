
{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ./modules/kanata.nix
      ./modules/fish.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
   # Enable the uinput module
  boot.kernelModules = [ "uinput" ];

  # Enable uinput
  hardware.uinput.enable = true;

  # Set up udev rules for uinput
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
  '';

  # Ensure the uinput group exists
  users.groups.uinput = { };

  # Add the Kanata service user to necessary groups
  systemd.services.kanata-internalKeyboard.serviceConfig = {
    SupplementaryGroups = [
      "input"
      "uinput"
    ];
  };

  networking.hostName = "nixos-btw"; # Define your hostname.
  virtualisation.vmware.guest.enable = true;
  hardware.graphics.enable = true;

  networking.networkmanager.enable = true;
  networking.nameservers = ["1.1.1.1" "8.8.8.8"];

  # Set your time zone.
  time.timeZone = "America/New_York";

  # services.xserver.enable = true;
  services.displayManager.ly.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  environment.etc = {
    "resolv.conf".text = "nameserver 1.1.1.1\n";
  };


  

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mic = {
    isNormalUser = true;
    extraGroups = [ "wheel" "uinput"]; # Enable ‘sudo’ for the user.
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
    open-vm-tools
    foot
    wmenu
    wl-clipboard
    grim
    slurp
    swaybg
    firefox
    gtk4
    xwayland
    kanata
  ];


  fonts.packages = with pkgs; [
	nerd-fonts.jetbrains-mono
  ];
 
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.11"; 

}

