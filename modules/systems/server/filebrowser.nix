{ config, pkgs, ... }:

{
  # ============================================================================
  # FILEBROWSER QUANTUM (Modern File Browser)
  # ============================================================================

  # 1. Mount the 2TB SSD (ssd2)
  fileSystems."/mnt/ssd2" = {
    device = "/dev/disk/by-uuid/303e89ff-115c-4dd6-ab35-c1caafe6c30d";
    fsType = "ext4";
    options = [
      "nofail"
      "defaults"
    ];
  };

  # 2. Docker Container Setup
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      filebrowser = {
        image = "gtstef/filebrowser:stable";
        ports = [ "8085:80" ];
        environment = {
          # Use environment variables for everything to avoid YAML issues
          FB_DATABASE = "/database/filebrowser.db";
          FB_ROOT = "/srv";
          FB_PORT = "80";
          FB_ADDR = "0.0.0.0";
          FB_LOG = "stdout";
          FILEBROWSER_ADMIN_PASSWORD = "admin";
          # Permission fixes: Map to 'mic' user (1000) and 'users' group (100)
          PUID = "1000";
          PGID = "100";
        };
        volumes = [
          "/mnt/ssd2/files:/srv"
          "/var/lib/filebrowser/data:/database"
        ];
      };
    };
  };

  # 3. Ensure data directory exists
  systemd.tmpfiles.rules = [
    "d /var/lib/filebrowser 0777 root root -"
    "d /var/lib/filebrowser/data 0777 root root -"
    "d /mnt/ssd2/files 0775 mic users -"
  ];

  # 4. Networking
  networking.firewall.allowedTCPPorts = [ 8085 ];
}
