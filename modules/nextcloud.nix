{ config, pkgs, lib, ... }:

{
  # Nextcloud Setup
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud33;
    hostName = "100.91.229.67";

    # Use PostgreSQL as the database (enabled automatically by database.createLocally)
    database.createLocally = true;
    config = {
      dbtype = "pgsql";
      adminpassFile = "/etc/nextcloud-admin-pass";
      adminuser = "admin";
    };

    # Basic performance/security settings
    settings = {
      "maintenance_window_start" = 1;
      trusted_domains = [ "optiplex-server" "optiplex-server.local" "100.91.229.67" ];
      overwriteprotocol = "http";
      "overwrite.cli.url" = "http://100.91.229.67";
    };

    # Enable caching for better performance
    configureRedis = true;
  };

  # Open the firewall for HTTP and HTTPS
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # Reminder: You MUST create /etc/nextcloud-admin-pass before switching
  # echo "yourpassword" | sudo tee /etc/nextcloud-admin-pass
  # sudo chown nextcloud:nextcloud /etc/nextcloud-admin-pass
  # sudo chmod 600 /etc/nextcloud-admin-pass
}
