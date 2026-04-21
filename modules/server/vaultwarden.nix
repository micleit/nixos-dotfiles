{ config, pkgs, lib, ... }:

{
  # Vaultwarden Setup (Bitwarden-compatible password manager)
  # Access at http://100.91.229.67:8000
  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    config = {
      domain = "http://100.91.229.67:8000";
      signupsAllowed = false;
      invitationsAllowed = false;
      showPasswordHint = false;
      logLevel = "info";
      logFile = "/var/log/vaultwarden/vaultwarden.log";
      icon_cache_ttl = 2592000;
      icon_cache_negttl = 259200;
    };
  };

  # PostgreSQL database
  services.postgresql = {
    enable = true;
    ensureUsers = [
      {
        name = "vaultwarden";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = [ "vaultwarden" ];
  };

  # Open port 8000 for Vaultwarden
  networking.firewall.allowedTCPPorts = [ 8000 ];

  # Log rotation for vaultwarden
  services.logrotate = {
    enable = true;
    paths.vaultwarden = {
      path = "/var/log/vaultwarden/*.log";
      frequency = "daily";
      rotate = 10;
      compress = true;
      delaycompress = true;
      missingok = true;
    };
  };

  # Notes:
  # - Access at http://100.91.229.67:8000
  # - Port 8000 is free and doesn't conflict with Nextcloud (80/443) or Immich (2283)
  # - Database and logs are automatically managed
}
