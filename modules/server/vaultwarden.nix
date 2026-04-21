{ config, pkgs, lib, ... }:

{
  # Vaultwarden Setup (Bitwarden-compatible password manager)
  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    config = {
      domain = "100.91.229.67";
      signupsAllowed = false;
      invitationsAllowed = false;
      showPasswordHint = false;
      logLevel = "info";
      logFile = "/var/log/vaultwarden/vaultwarden.log";
    };
  };

  # PostgreSQL database (created automatically if necessary)
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

  # Open the firewall for HTTP and HTTPS
  networking.firewall.allowedTCPPorts = [ 80 443 ];

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

  # Reminder: Configure these before switching:
  # 1. Set domain in services.vaultwarden.config.domain
  # 2. Generate a JWT secret: openssl rand -base64 32
  # 3. Add JWT_SECRET to services.vaultwarden.config if needed
  # 4. Set up reverse proxy (Nginx/Caddy) for HTTPS
  # 5. Consider enabling SHOW_PASSWORD_HINT = false for security
}
