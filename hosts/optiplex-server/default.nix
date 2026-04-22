{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/server/cloudflare-tunnel.nix
    ../../modules/server/immich.nix
    ../../modules/server/samba.nix
    ../../modules/server/nextcloud.nix
    ../../modules/server/navidrome.nix
    ../../modules/server/vaultwarden.nix
  ];

  # ============================================================================
  # BOOT & KERNEL
  # ============================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "fuse" ];
  boot.kernelModules = [ "snd_hda_intel" ];
  hardware.enableAllFirmware = true;

  # ============================================================================
  # NETWORKING & SERVICES
  # ============================================================================
  networking.hostName = "optiplex-server";
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  services.openssh.enable = true;
  services.tailscale.enable = true;

  # Sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Time & Locale
  time.timeZone = "America/New_York";
  services.timesyncd.enable = true;

  # Mounting / Storage Services
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Display Manager (TUI)
  services.displayManager.ly.enable = true;

  # ============================================================================
  # HEADLESS AUDIO FIXES
  # ============================================================================
  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id.indexOf("org.freedesktop.login1.") == 0 && subject.isInGroup("audio")) {
        return polkit.Result.YES;
      }
    });
  '';

  # Ensure PipeWire starts and stays running without a monitor/active session
  systemd.user.services.pipewire.wantedBy = [ "default.target" ];
  systemd.user.services.wireplumber.wantedBy = [ "default.target" ];

  # ============================================================================
  # USER & SECURITY
  # ============================================================================
  users.users.mic = {
    isNormalUser = true;
    extraGroups = [ "wheel" "uinput" "storage" "video" "optical" "cdrom" "audio" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKxCjlGFtiU6rrgryYhKmp0u6cbPhXPYm6IRkh9mSGL0 <comment>" #mbp
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM2H3Qy26Y3JV0p5WhpR89pE4hi7tssLbL/BYm+RsKd2 mic@headless-m1" #headlessm1
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIArDsvxPAbb7S2XhflttHFnsv5Sfyb/Z1mZIf+1PGJdn mic@nixos-btw" #desktop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUGAfMHR2crHkfh6Wo73N0NW7w5VdBk476kEvF4QBxu mic@optiplex-server" #optiplex-server
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHgcQZ2TjpwiJAeeOUAywqpZ+xSxIYjeN7FBn0w59zHP mic@acer-nixos" #acer
    ];
  };

  programs.fish.enable = true;

  # ============================================================================
  # ESSENTIAL SYSTEM PACKAGES
  # ============================================================================
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    unzip
    ffmpeg
    btop
    gcc
    gnumake
    curl
    pciutils
    usbutils
    alsa-utils
    vlc # VLC with ncurses/terminal interface (nvlc)
    (mpv-unwrapped.override { cddaSupport = true; })
  ];

  # ============================================================================
  # NIX SETTINGS
  # ============================================================================
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  environment.pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];

  system.stateVersion = "26.05";
}
