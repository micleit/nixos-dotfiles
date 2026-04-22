{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Vaultwarden Setup (Bitwarden-compatible password manager)
  services.vaultwarden = {
    enable = true;
    config = {
      domain = "https://vaultwarden.53729123.xyz";
      rocketAddress = "127.0.0.1";
      rocketPort = 8222;
      signupsAllowed = true;
      invitationsAllowed = false;
      showPasswordHint = false;
      logLevel = "info";
      logFile = "/var/log/vaultwarden/vaultwarden.log";
      icon_cache_ttl = 2592000;
      icon_cache_negttl = 259200;
    };
  };

  # Create log directory with proper permissions
  systemd.tmpfiles.rules = [
    "d /var/log/vaultwarden 0755 vaultwarden vaultwarden - -"
  ];

  # Allow vaultwarden to write to log directory despite ProtectSystem=strict
  systemd.services.vaultwarden.serviceConfig = {
    ReadWritePaths = [ "/var/log/vaultwarden" ];
  };

  # Vaultwarden listens on localhost:8222 only (cloudflare tunnel handles external access)
}

