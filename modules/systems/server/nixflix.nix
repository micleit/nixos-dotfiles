{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

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
          {
            enable = true;
            name = "The Pirate Bay";
            definitionName = "thepiratebay";
          }
          {
            enable = true;
            name = "TorrentDownload";
            definitionName = "torrentdownload";
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
        Address = "*";
        AuthSubnetWhitelistEnabled = true;
        AuthSubnetWhitelist = "127.0.0.1/32,100.64.0.0/10";
        Password_PBKDF2 = "PBKDF2@64@ELU+8EOYJRpR9G2ZSalqHA==@ImcbKmHbwj3huiwMaNf7fs2LGlJU9Owy0+AP9jwmRb4W2OgeM5A/D6c0tBjZRShytMJDGQ2RpbOpiE0bhcVlwQ==";
      };
    };

    jellyfin = {
      enable = true;
      network.localNetworkAddresses = [ ];
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

  # Ensure Jellyfin enables legacy authorization for older/homebrew clients (e.g. WiiFin)
  systemd.services.jellyfin.preStart = lib.mkAfter ''
    if [ -f /var/lib/jellyfin/config/system.xml ]; then
      ${pkgs.gnused}/bin/sed -i 's/<EnableLegacyAuthorization>false<\/EnableLegacyAuthorization>/<EnableLegacyAuthorization>true<\/EnableLegacyAuthorization>/' /var/lib/jellyfin/config/system.xml
    fi
  '';

  # Fix radarr-config: Radarr v5.15+/v6 requires 'allowedHosts' to not be null.
  # The upstream nixflix module omits allowedHosts, causing HTTP 400 Bad Request.
  systemd.services.radarr-config.script = lib.mkForce ''
    set -eu

    BASE_URL="http://127.0.0.1:7878/api/v3"

    echo "Fetching current host configuration..."
    HOST_CONFIG=$(${pkgs.curl}/bin/curl --variable apiKey@/var/lib/nixflix/secrets/radarr_api_key --expand-header "X-Api-Key: {{apiKey:trim}}" -s -f "$BASE_URL/config/host" 2>/dev/null)

    if [ -z "$HOST_CONFIG" ]; then
      echo "Failed to fetch host configuration"
      exit 1
    fi

    CONFIG_ID=$(echo "$HOST_CONFIG" | ${pkgs.jq}/bin/jq -r '.id')

    echo "Building configuration..."
    NEW_CONFIG=$(echo "$HOST_CONFIG" | ${pkgs.jq}/bin/jq \
      --rawfile apiKeyContent /var/lib/nixflix/secrets/radarr_api_key \
      --rawfile passwordContent /var/lib/nixflix/secrets/admin_password \
      --arg username admin \
      '. + {
        bindAddress: "127.0.0.1",
        port: 7878,
        sslPort: 9898,
        enableSsl: false,
        launchBrowser: false,
        authenticationMethod: "forms",
        authenticationRequired: "enabled",
        allowedHosts: (.allowedHosts // ""),
        analyticsEnabled: false,
        username: $username,
        password: ($passwordContent | sub("\n+$"; "")),
        passwordConfirmation: ($passwordContent | sub("\n+$"; "")),
        apiKey: ($apiKeyContent | sub("\n+$"; ""))
      }')

    echo "Updating Radarr configuration via API..."
    CURL_DATA_FILE=$(mktemp)
    _CURL_CLEANUP_FILES="''${_CURL_CLEANUP_FILES:-} $CURL_DATA_FILE"
    trap 'rm -f $_CURL_CLEANUP_FILES' EXIT
    cat > "$CURL_DATA_FILE" <<DATA_EOF
    $NEW_CONFIG
    DATA_EOF

    ${pkgs.curl}/bin/curl --variable apiKey@/var/lib/nixflix/secrets/radarr_api_key --expand-header "X-Api-Key: {{apiKey:trim}}" -s -X PUT --data-binary @$CURL_DATA_FILE --header "Content-Type: application/json" -f "$BASE_URL/config/host/$CONFIG_ID" > /dev/null

    echo "Configuration updated successfully"

    echo "Restarting radarr service..."
    systemctl restart radarr.service
    echo "Radarr service restarted"
  '';
}
