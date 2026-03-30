{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/samba.nix
    # Other system-wide modules
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
  networking.hostName = "desktop-nixos";
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 21115 21116 21117 21118 21119 ];
        allowedUDPPorts = [ 21116 ];
      };

  systemd.services.rustdesk = {
        description = "RustDesk Remote Desktop Server";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.rustdesk}/bin/rustdesk --service";
          Restart = "always";
        };
      };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ 
      pkgs.xdg-desktop-portal-gtk 
      pkgs.xdg-desktop-portal-hyprland
    ];
    config.common.default = "*";
  };

  # Display Manager
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
    shell = pkgs.fish;
  };

  programs.fish.enable = true; # System level enable

  security.sudo.extraConfig = "Defaults pwfeedback";
  security.polkit.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;

  # ============================================================================
  # ESSENTIAL SYSTEM PACKAGES
  # ============================================================================
  environment.systemPackages = with pkgs; [
    vim wget git librewolf alacritty 
    adi1090x-plymouth-themes
    gcc gnumake curl
    rustdesk
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QUICKSHELL_PLUGIN_PATH = "${inputs.noctalia-qs.packages.${pkgs.stdenv.hostPlatform.system}.default}/lib/quickshell/plugins";
  };

  # ============================================================================
  # GAMING & FONTS (System Level support)
  # ============================================================================
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;
  programs.localsend.enable = true;

  # ============================================================================
  # NIX SETTINGS
  # ============================================================================
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.11"; 
}
