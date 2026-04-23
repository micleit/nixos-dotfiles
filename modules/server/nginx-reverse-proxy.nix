{
  config,
  pkgs,
  lib,
  ...
}:

let
  domain = "53729123.xyz";
  email = "admin@53729123.xyz";
in
{
  # Enable nginx reverse proxy
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;

    # Virtual hosts for each subdomain
    virtualHosts = {
      # Root domain redirect
      "${domain}" = {
        enableACME = true;
        forceSSL = true;
        root = pkgs.writeTextDir "index.html" ''
          <!DOCTYPE html>
          <html>
          <head><title>53729123.xyz</title></head>
          <body>
            <h1>Services</h1>
            <ul>
              <li><a href="https://immich.${domain}">Immich (Photos)</a></li>
              <li><a href="https://nextcloud.${domain}">Nextcloud (Files)</a></li>
              <li><a href="https://navidrome.${domain}">Navidrome (Music)</a></li>
              <li><a href="https://vaultwarden.${domain}">Vaultwarden (Passwords)</a></li>
            </ul>
          </body>
          </html>
        '';
      };

      # Immich
      "immich.${domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:2283";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            client_max_body_size 50G;
          '';
        };
      };

      # Nextcloud
      "nextcloud.${domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:80";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_redirect off;
            proxy_buffering off;
            proxy_request_buffering off;
          '';
        };
      };

      # Navidrome
      "navidrome.${domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:4533";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };

      # Vaultwarden
      "vaultwarden.${domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8222";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto https;
            proxy_redirect off;
          '';
        };
      };
    };
  };

  # Configure ACME (Let's Encrypt)
  security.acme = {
    acceptTerms = true;
    defaults.email = email;
    certs = {
      "${domain}" = {
        domain = domain;
        extraDomainNames = [
          "immich.${domain}"
          "nextcloud.${domain}"
          "navidrome.${domain}"
          "vaultwarden.${domain}"
        ];
        webroot = "/var/lib/acme/challenges";
      };
    };
  };

  # Disable vaultwarden-nginx module's self-signed cert setup
  # (conflicts with our ACME setup)
  services.vaultwarden.config.domain = lib.mkForce "https://vaultwarden.${domain}";

  # Firewall: Allow HTTP/HTTPS
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  # Ensure nginx starts after ACME certs are ready
  systemd.services.nginx.after = [ "acme-finished-${domain}.target" ];
  systemd.services.nginx.wants = [ "acme-finished-${domain}.target" ];
}
