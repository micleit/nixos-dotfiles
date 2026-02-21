
{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      /etc/nixos/hardware-configuration.nix
      ./modules/kanata.nix
      ./modules/fish.nix
    ];

  boot.supportedFilesystems = ["fuse"];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
   # Enable the uinput module
  boot.kernelModules = [ "uinput" "vmw_balloon" "vmwgfx" "vmw_vmci" "vsock"];

  # Enable uinput
  hardware.uinput.enable = true;

  # Set up udev rules for uinput
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
    KERNEL=="sr0", GROUP="cdrom", MODE="0660"
 ''
  ;

  # Ensure the uinput group exists
  users.groups.uinput = { };

  # Add the Kanata service user to necessary groups
  systemd.services.kanata-internalKeyboard.serviceConfig = {
    SupplementaryGroups = [
      "input"
      "uinput"
    ];
  };

security.wrappers = {
  cdrecord = {
    source = "${pkgs.cdrtools}/bin/cdrecord";
    owner = "root";
    group = "cdrom";
    capabilities = "cap_sys_rawio,cap_sys_nice,cap_ipc_lock+ep";
    permissions = "u+rx,g+rx,o+rx,u+s";
  };
};


security.pam.loginLimits = [
  { domain = "@cdrom"; item = "memlock"; type = "-"; value = "unlimited"; }
  { domain = "@cdrom"; item = "nice"; type = "-"; value = "-20"; }
];

  networking.hostName = "nixos-btw"; # Define your hostname.
  hardware.graphics.enable = true;
  

  networking.networkmanager.enable = true;
  networking.nameservers = ["1.1.1.1" "8.8.8.8"];
  services.openssh.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  services.displayManager.ly.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  programs.xwayland.enable = true;

  environment.etc = {
    "resolv.conf".text = "nameserver 1.1.1.1\n";
  };

  # auto mounts new disks
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  users.users.mic = {
    isNormalUser = true;
    extraGroups = [ "wheel" "uinput" "optical" "storage" "cdrom"]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };
  programs.firefox.enable = true;
  hardware.parallels.enable = true;

  environment.systemPackages = with pkgs; [
    vim 
    wget
    librewolf
    git
    alacritty
    open-vm-tools
    foot
    wmenu
    wl-clipboard
    grim
    slurp
    swaybg
    gtk3
    xwayland-satellite
    kanata
    ffmpeg
    unzip
    brasero
    vlc
  ];
  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
	nerd-fonts.jetbrains-mono
  ];
 
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.11"; 

}

