{
  config,
  pkgs,
  lib,
  ...
}:

let
  domain = "optiplex-server.tail48220b.ts.net";
  certDir = "/var/lib/vaultwarden-certs";
in
{
  # Pre-generate self-signed certificate at system activation
  system.activationScripts.vaultwarden-certs = {
    text = ''
      mkdir -p ${certDir}
      if [ ! -f ${certDir}/cert.pem ]; then
        ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:4096 \
          -keyout ${certDir}/key.pem \
          -out ${certDir}/cert.pem \
          -days 3650 -nodes -subj "/CN=${domain}"
      fi
      chmod 644 ${certDir}/key.pem
      chmod 644 ${certDir}/cert.pem
      chown nginx:nginx ${certDir}
      chown nginx:nginx ${certDir}/*.pem
    '';
    deps = [];
  };

  # Nginx reverse proxy for Vaultwarden with HTTPS
  services.nginx = {
    enable = true;
    virtualHosts."${domain}" = {
      enableACME = false;
      forceSSL = true;
      sslCertificate = "${certDir}/cert.pem";
      sslCertificateKey = "${certDir}/key.pem";
      
      locations."/" = {
        proxyPass = "http://127.0.0.1:8222";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto https;
        '';
      };
    };
  };

  # Open ports for nginx
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # Notes:
  # - Access at https://optiplex-server.tail48220b.ts.net
  # - Self-signed certificate for the Tailscale domain
  # - Nginx listens on 80/443 and proxies to vaultwarden on localhost:8222
}
