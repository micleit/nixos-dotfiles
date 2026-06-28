{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.nixflix.nixosModules.default
  ];

  nixflix = {
    enable = true;
    mediaDir = "/mnt/ssd2/files/media";
    downloadsDir = "/mnt/ssd2/torrent";
    mediaUsers = [ "mic" ];

    # Scaffolding
    postgres.enable = true;
    nginx = {
      enable = true;
      addHostsEntries = true;
    };

    # Core Services - Using dummy keys
    sonarr = {
      enable = true;
      config = {
        apiKey._secret = "/var/lib/nixflix/secrets/sonarr_api_key";
        hostConfig = {
          username = "admin";
          password._secret = "/var/lib/nixflix/secrets/admin_password";
        };
      };
    };
    radarr = {
      enable = true;
      config = {
        apiKey._secret = "/var/lib/nixflix/secrets/radarr_api_key";
        hostConfig = {
          username = "admin";
          password._secret = "/var/lib/nixflix/secrets/admin_password";
        };
      };
    };
    prowlarr = {
      enable = true;
      config = {
        apiKey._secret = "/var/lib/nixflix/secrets/prowlarr_api_key";
        hostConfig = {
          username = "admin";
          password._secret = "/var/lib/nixflix/secrets/admin_password";
        };
        indexers = [
          {
            enable = true;
            name = "YTS";
            definitionName = "yts";
          }
        ];
      };
    };

    lidarr = {
      enable = true;
      mediaDirs = [
        "/mnt/ssd2/files/media/music"
        "/music"
      ];
      config = {
        apiKey._secret = "/var/lib/nixflix/secrets/lidarr_api_key";
        hostConfig = {
          username = "admin";
          password._secret = "/var/lib/nixflix/secrets/admin_password";
        };
      };
      settings = {
        metadata = {
          renameTracks = true;
        };
      };
    };

    seerr = {
      enable = true;
      apiKey._secret = "/var/lib/nixflix/secrets/seerr_api_key";
    };

    torrentClients.qbittorrent = {
      enable = true;
      serverConfig.Preferences.WebUI = {
        AuthSubnetWhitelistEnabled = true;
        AuthSubnetWhitelist = "127.0.0.1/32";
        Password_PBKDF2 = "PBKDF2@64@ELU+8EOYJRpR9G2ZSalqHA==@ImcbKmHbwj3huiwMaNf7fs2LGlJU9Owy0+AP9jwmRb4W2OgeM5A/D6c0tBjZRShytMJDGQ2RpbOpiE0bhcVlwQ==";
      };
    };

    jellyfin = {
      enable = true;
      apiKey._secret = "/var/lib/nixflix/secrets/jellyfin_api_key";
      users.admin = {
        policy.isAdministrator = true;
        password._secret = "/var/lib/nixflix/secrets/admin_password";
      };
    };

    # Optional but recommended for "Nixflix" feel
    theme = {
      enable = true;
      name = "overseerr";
    };

    flaresolverr.enable = false;
  };

  # Byparr: Modern FlareSolverr drop-in replacement via Docker
  virtualisation.oci-containers.containers."byparr" = {
    image = "ghcr.io/thephaseless/byparr:latest";
    ports = [ "127.0.0.1:8191:8191" ];
    environment = {
      LOG_LEVEL = "info";
    };
  };
}
