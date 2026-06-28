{ config, pkgs, ... }:

{
  services.slskd = {
    enable = true;
    domain = null; # We'll expose it via Cloudflare Tunnel later, so keep it local for now
    environmentFile = "/var/lib/nixflix/secrets/slskd.env";
    settings = {
      directories = {
        downloads = "/mnt/ssd2/files/media/music/slskd-downloads";
        incomplete = "/mnt/ssd2/files/media/music/slskd-downloads/.incomplete";
      };
      shares.directories = [ "/mnt/ssd2/files/media/music" ];
      web.port = 5030;
    };
  };

  # Open the Soulseek listen port on the firewall if you want to be connectable
  # but since we are behind a VPN, we don't need to open the host firewall.
  # The VPN handles it (or we are passive).

  # Allow slskd to write to the media directory
  systemd.services.slskd.serviceConfig.ReadWritePaths = [ "/mnt/ssd2/files/media/music/slskd-downloads" ];

  # Add slskd to the media group
  users.users.slskd.extraGroups = [ "media" ];
}