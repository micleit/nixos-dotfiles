{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Seafile Docker Deployment
  # Uses the official multi-container setup (Seafile + MariaDB + Memcached)
  # Behind Cloudflare Tunnel, so we map Seahub to port 8083

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      # Database
      seafile-mysql = {
        image = "mariadb:10.11";
        environment = {
          MYSQL_ROOT_PASSWORD = "seafile_db_password";
          MYSQL_LOG_CONSOLE = "true";
        };
        volumes = [
          "/var/lib/seafile/mysql:/var/lib/mysql"
        ];
      };

      # Cache
      seafile-memcached = {
        image = "memcached:1.6.18";
        cmd = [
          "memcached"
          "-m"
          "256"
        ];
      };

      # Seafile Server
      seafile = {
        image = "seafileltd/seafile-mc:latest";
        dependsOn = [
          "seafile-mysql"
          "seafile-memcached"
        ];
        ports = [
          "8083:80" # Seahub (Web UI)
        ];
        environment = {
          DB_HOST = "seafile-mysql";
          DB_ROOT_PASSWD = "seafile_db_password";
          TIME_ZONE = "America/New_York";
          SEAFILE_ADMIN_EMAIL = "mic@53729123.xyz";
          SEAFILE_ADMIN_PASSWORD = "seafile_password_change_me";
          SEAFILE_SERVER_LETSENCRYPT = "false";
          SEAFILE_SERVER_HOSTNAME = "seafile.53729123.xyz";
        };
        volumes = [
          "/var/lib/seafile/data:/shared"
        ];
      };
    };
  };

  # Ensure the data directory exists
  systemd.tmpfiles.rules = [
    "d /var/lib/seafile 0755 root root -"
    "d /var/lib/seafile/mysql 0755 root root -"
    "d /var/lib/seafile/data 0755 root root -"
  ];

  # Open port for local access if needed
  networking.firewall.allowedTCPPorts = [ 8083 ];

  # Note: To complete the setup, add a public hostname in Cloudflare Zero Trust:
  # seafile.53729123.xyz -> http://localhost:8083
}
