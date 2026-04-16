{ config, pkgs, ... }:

{
  # 1. Mount the old Laptop Root Partition (2TB SSD)
  fileSystems."/mnt/old-laptop" = {
    device = "/dev/disk/by-uuid/7290c982-8ba3-422f-9eda-4831b7255260";
    fsType = "ext4";
    options = [ "nofail" "defaults" ];
  };

  # 2. Reach inside the old /var/lib/immich and map it to the new one
  fileSystems."/var/lib/immich" = {
    device = "/mnt/old-laptop/var/lib/immich";
    fsType = "none";
    options = [ "bind" "nofail" ];
    depends = [ "/mnt/old-laptop" ];
  };

  # 3. Standard Immich Service Setup
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    port = 2283;
    mediaLocation = "/var/lib/immich";
  };

  networking.firewall.allowedTCPPorts = [ 2283 ];
  users.users.immich.extraGroups = [ "users" ];
}
