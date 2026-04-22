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
      signupsAllowed = false;
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

  # Open port 8222 for internal Vaultwarden (localhost only)
  # Nginx will proxy to it from port 8443

  # Notes:
  # - Access at http://100.91.229.67:8000
  # - Port 8000 is free and doesn't conflict with Nextcloud (80/443) or Immich (2283)
  # - Uses SQLite (simpler than PostgreSQL for personal server)
}
