{ config, pkgs, lib, ... }:

{
  # Vaultwarden Setup (Bitwarden-compatible password manager)
  # Access via Tailscale: https://<tailscale-hostname>.ts.net
  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    config = {
      domain = "https://optiplex-server.ts.net";
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

  # Nginx reverse proxy for Tailscale access
  services.nginx = {
    enable = true;
    virtualHosts."optiplex-server.ts.net" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:80";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
  };

  # Firewall rules
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

  # Ensure Tailscale is enabled
  services.tailscale.enable = true;

  # Notes:
  # - Access via https://optiplex-server.ts.net from any Tailscale client
  # - No port forwarding needed; traffic stays within your Tailnet
  # - Update domain above if you rename the host
  # - First login creates admin account; signups disabled after
}
