{ config, pkgs, lib, ... }:

{
  services.navidrome = {
    enable = true;
    settings = {
      # Point to the bind-mounted location
      MusicFolder = "/var/lib/navidrome/music";
      Address = "0.0.0.0";
      Port = 4533;
      ScanSchedule = "@every 1h";
    };
  };

  # Bind mount the music folder so Navidrome can access it directly.
  # This bypasses the home directory's restricted permissions.
  fileSystems."/var/lib/navidrome/music" = {
    device = "/home/mic/Sorted";
    fsType = "none";
    options = [ "bind" "ro" ];
  };

  # Ensure the mount point exists
  systemd.tmpfiles.rules = [
    "d /var/lib/navidrome/music 0755 navidrome navidrome -"
  ];

  networking.firewall.allowedTCPPorts = [ 4533 ];
}
