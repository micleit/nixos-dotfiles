{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
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

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };
  # one of "ignore", "poweroff", "reboot", "halt", "kexec", "suspend", "hibernate", "hybrid-sleep", "suspend-then-hibernate", "lock"

  # ============================================================================
  # NETWORKING & SERVICES
  # ============================================================================
  networking.hostName = "acer-nixos";
  networking.networkmanager.enable = true;
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

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

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      21115
      21116
      21117
      21118
      21119
    ];
    allowedUDPPorts = [ 21116 ];
  };

  # ============================================================================
  # GRAPHICS & HYPRLAND (System Level)
  # ============================================================================
  # services.sunshine.enable = true;
  # services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # hardware.nvidia = {
  #   modesetting.enable = true;
  #   open = false;
  #   nvidiaSettings = true;
  #   package = config.boot.kernelPackages.nvidiaPackages.stable;
  # };

  # programs.hyprland = {
  #   enable = true;
  #   xwayland.enable = true;
  # };

  # xdg.portal = {
  #   enable = true;
  #   extraPortals = [
  #     pkgs.xdg-desktop-portal-gtk
  #     pkgs.xdg-desktop-portal-hyprland
  #   ];
  #   config.common.default = "*";
  # };

  # Display Manager
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.ly.enable = true;

  # ============================================================================
  # AUDIO (Pipewire)
  # ============================================================================
  # services.pulseaudio.enable = false;
  # security.rtkit.enable = true;
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  # };

  # ============================================================================
  # USER & SECURITY
  # ============================================================================
  users.users.mic = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "optical"
      "storage"
      "cdrom"
    ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKxCjlGFtiU6rrgryYhKmp0u6cbPhXPYm6IRkh9mSGL0 <comment>" # mbp
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM2H3Qy26Y3JV0p5WhpR89pE4hi7tssLbL/BYm+RsKd2 mic@headless-m1" # headlessm1
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIArDsvxPAbb7S2XhflttHFnsv5Sfyb/Z1mZIf+1PGJdn mic@nixos-btw" # desktop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUGAfMHR2crHkfh6Wo73N0NW7w5VdBk476kEvF4QBxu mic@optiplex-server" # optiplex-server
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHgcQZ2TjpwiJAeeOUAywqpZ+xSxIYjeN7FBn0w59zHP mic@acer-nixos" # acer
    ];
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
    vim
    wget
    git
    adi1090x-plymouth-themes
    gcc
    gnumake
    curl
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QUICKSHELL_PLUGIN_PATH = "${
      inputs.noctalia-qs.packages.${pkgs.stdenv.hostPlatform.system}.default
    }/lib/quickshell/plugins";
  };

  # ============================================================================
  # GAMING & FONTS (System Level support)
  # ============================================================================
  # programs.steam = {
  #   enable = true;
  #   gamescopeSession.enable = true;
  # };
  # programs.gamemode.enable = true;
  # programs.localsend.enable = true;

  # ============================================================================
  # NIX SETTINGS
  # ============================================================================
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.11";
}
