{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Nextcloud Setup
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud33;
    hostName = "localhost";
    https = false;

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
      trusted_domains = [
        "localhost"
        "127.0.0.1"
      ];
    };

    # Enable caching for better performance
    configureRedis = true;
  };

  # Nextcloud listens on localhost:80 only
  networking.firewall.allowedTCPPorts = [ ];

  # Reminder: You MUST create /etc/nextcloud-admin-pass before switching
  # echo "yourpassword" | sudo tee /etc/nextcloud-admin-pass
  # sudo chown nextcloud:nextcloud /etc/nextcloud-admin-pass
  # sudo chmod 600 /etc/nextcloud-admin-pass
}
