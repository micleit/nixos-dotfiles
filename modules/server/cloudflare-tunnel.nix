{ config, pkgs, lib, ... }:

let
  domain = "53729123.xyz";
  tunnelName = "optiplex-server";
in
{
  # Install cloudflared
  environment.systemPackages = with pkgs; [
    cloudflared
  ];

  # Cloudflared tunnel service
  systemd.services.cloudflared = {
    description = "Cloudflare Tunnel";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      User = "cloudflared";
      Group = "cloudflared";
      ExecStart = ''
        ${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token $TUNNEL_TOKEN
      '';
      Restart = "on-failure";
      RestartSec = "5s";
      EnvironmentFile = "/etc/cloudflared/tunnel.env";
    };
  };

  # Create cloudflared user
  users.users.cloudflared = {
    isSystemUser = true;
    group = "cloudflared";
    home = "/var/lib/cloudflared";
    createHome = true;
  };

  users.groups.cloudflared = { };

  # Create tunnel.env file location (user must populate with TUNNEL_TOKEN)
  systemd.tmpfiles.rules = [
    "d /etc/cloudflared 0755 root root -"
    "f /etc/cloudflared/tunnel.env 0644 root root -"
  ];

  # No need to open firewall—tunnel is outbound only
}
