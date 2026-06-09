{
  config,
  pkgs,
  lib,
  ...
}:

{
  services.navidrome = {
    enable = true;
    settings = {
      # Moved music to a top-level directory to avoid home directory permission issues
      MusicFolder = "/music";
      Address = "0.0.0.0";
      Port = 4533;
      ScanSchedule = "@every 1h";
    };
  };

  # Automatically fix permissions for new files added to /music using ACLs
  # This ensures Navidrome can always read new music without manual chmod
  systemd.tmpfiles.rules = [
    "d /music 0755 mic users - -"
    "A+ /music - - - - d:u::rwx,d:g::rwx,d:o::rx,u::rwx,g::rwx,o::rx"
  ];

  networking.firewall.allowedTCPPorts = [ 4533 ];
}
