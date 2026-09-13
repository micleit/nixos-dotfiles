{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ============================================================================
  # ZENNOTES (Keyboard-first Markdown Notes Web App & Server)
  # ============================================================================

  # Docker Container Setup
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      zennotes = {
        image = "adibhanna/zennotes:latest";
        # Port 8484 on host (7878 in container) to avoid conflict with Radarr on 7878
        ports = [ "8484:7878" ];
        user = "1000:100"; # Run as user 'mic' (1000) and 'users' group (100)
        environment = {
          ZENNOTES_BIND = "0.0.0.0:7878";
          ZENNOTES_CONFIG_PATH = "/data/server.json";
          ZENNOTES_DEFAULT_VAULT_PATH = "/workspace";
          ZENNOTES_BROWSE_ROOTS = "/workspace";
          ZENNOTES_AUTH_TOKEN_FILE = "/data/auth-token";
          ZENNOTES_BEHIND_TLS = "1";
          ZENNOTES_PERSIST_SESSIONS = "1";
          ZENNOTES_ALLOWED_ORIGINS = "https://zennotes.53729123.xyz,http://localhost:8484,http://127.0.0.1:8484,http://new-optiplex:8484";
        };
        volumes = [
          "/var/lib/zennotes/vault:/workspace"
          "/var/lib/zennotes/data:/data"
        ];
      };
    };
  };

  # Ensure state and vault directories exist with appropriate ownership
  systemd.tmpfiles.rules = [
    "d /var/lib/zennotes 0755 mic users -"
    "d /var/lib/zennotes/data 0755 mic users -"
    "d /var/lib/zennotes/vault 0755 mic users -"
  ];

  # Pre-start script to automatically initialize auth token if not already created
  systemd.services.docker-zennotes = {
    preStart = ''
      if [ ! -f /var/lib/zennotes/data/auth-token ]; then
        ${pkgs.openssl}/bin/openssl rand -hex 32 > /var/lib/zennotes/data/auth-token
        chown mic:users /var/lib/zennotes/data/auth-token
        chmod 600 /var/lib/zennotes/data/auth-token
      fi
    '';
  };

  # Open port 8484 in the firewall for LAN access
  networking.firewall.allowedTCPPorts = [ 8484 ];
}
