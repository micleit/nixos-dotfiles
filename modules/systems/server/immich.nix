{ config, pkgs, ... }:

{
  # 1. Mount the old Laptop Root Partition (2TB SSD)
  fileSystems."/mnt/ssd1" = {
    device = "/dev/disk/by-uuid/640ec30a-2257-4b72-8d22-4f9936056038";
    fsType = "ext4";
    options = [
      "nofail"
      "defaults"
    ];
  };

  # 2. Reach inside the old /var/lib/immich and map it to the new one
  fileSystems."/var/lib/immich" = {
    device = "/mnt/ssd1/immich-temp/";
    fsType = "none";
    options = [
      "bind"
      "nofail"
    ];
    depends = [ "/mnt/ssd1" ];
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
