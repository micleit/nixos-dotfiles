{ lib, pkgs, ... }:

{
  # Time & Locale
  time.timeZone = lib.mkDefault "America/New_York";
  services.timesyncd.enable = lib.mkDefault true;

  # Network & Remote Access
  services.openssh.enable = lib.mkDefault true;
  services.tailscale.enable = lib.mkDefault true;

  # Non-interactive rsync for fast transfers/backups
  security.sudo.extraRules = [
    {
      users = [ "mic" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/rsync";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Prevent server from sleeping or suspending
  systemd.targets.sleep.enable = lib.mkDefault false;
  systemd.targets.suspend.enable = lib.mkDefault false;
  systemd.targets.hibernate.enable = lib.mkDefault false;
  systemd.targets.hybrid-sleep.enable = lib.mkDefault false;

  services.logind.settings.Login = {
    HandleLidSwitch = lib.mkDefault "ignore";
    HandleSuspendKey = lib.mkDefault "ignore";
    HandleHibernateKey = lib.mkDefault "ignore";
    IdleAction = lib.mkDefault "ignore";
  };

  # Mounting / Storage Services
  services.devmon.enable = lib.mkDefault true;
  services.gvfs.enable = lib.mkDefault true;
  services.udisks2.enable = lib.mkDefault true;

  # Audio baseline
  security.rtkit.enable = lib.mkDefault true;
  services.pipewire = {
    enable = lib.mkDefault true;
    alsa.enable = lib.mkDefault true;
    alsa.support32Bit = lib.mkDefault true;
    pulse.enable = lib.mkDefault true;
  };

  # Common server CLI tools
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    curl
    btop
    pciutils
    usbutils
    ethtool
  ];
}
