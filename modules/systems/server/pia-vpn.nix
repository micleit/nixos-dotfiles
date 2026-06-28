{ config, pkgs, lib, ... }:

let
  # The physical interface and gateway (gathered from `ip route`)
  # In a dynamic environment, it's better to fetch this dynamically, but for NixOS
  # we can use a script that finds the default route.
  
  setupRouting = pkgs.writeShellScriptBin "setup-vpn-routing" ''
    # Find the default gateway and interface
    DEFAULT_GW=$(ip route show default | grep -v tun | awk '{print $3}' | head -n 1)
    DEFAULT_IF=$(ip route show default | grep -v tun | awk '{print $5}' | head -n 1)

    if [ -z "$DEFAULT_GW" ] || [ -z "$DEFAULT_IF" ]; then
      echo "Could not find default gateway or interface."
      exit 0
    fi

    # Create a custom routing table for bypassed traffic (table 200)
    ip route flush table 200 2>/dev/null || true
    ip route add default via $DEFAULT_GW dev $DEFAULT_IF table 200

    # Rule: Any packet with firewall mark 0x100 goes to table 200
    ip rule del fwmark 0x100 table 200 2>/dev/null || true
    ip rule add fwmark 0x100 table 200

    # IPTABLES: Mark packets from specific cgroups/users to bypass the VPN
    # The VPN creates a default route (0.0.0.0/1 or 0.0.0.0/0).
    # We mark traffic from cloudflared and tailscaled.

    # Flush existing rules in our custom chain
    iptables -t mangle -D OUTPUT -j VPN_BYPASS 2>/dev/null || true
    iptables -t mangle -F VPN_BYPASS 2>/dev/null || true
    iptables -t mangle -X VPN_BYPASS 2>/dev/null || true

    iptables -t mangle -N VPN_BYPASS
    iptables -t mangle -A OUTPUT -j VPN_BYPASS

    # Get UID/GIDs if needed, but systemd creates cgroups we can use, or we can use the owner module.
    # cloudflared runs as root usually, but its systemd service is cloudflared.service.
    # tailscaled runs as root as well. 
    # It is safer and more reliable to use the 'owner' module if we run them as specific users,
    # or match the socket if possible. 

    # Since tailscaled and cloudflared run as root, we can't just match by UID.
    # We will match by cgroup path.
    
    # Enable cgroup v2 matching
    iptables -t mangle -A VPN_BYPASS -m cgroup --path "system.slice/cloudflared-tunnel-*.scope" -j MARK --set-mark 0x100
    iptables -t mangle -A VPN_BYPASS -m cgroup --path "system.slice/cloudflared.service" -j MARK --set-mark 0x100
    iptables -t mangle -A VPN_BYPASS -m cgroup --path "system.slice/tailscaled.service" -j MARK --set-mark 0x100
    
    # Also bypass local network traffic (don't route 10.0.0.0/8, 192.168.0.0/16, etc. out the VPN)
    iptables -t mangle -A VPN_BYPASS -d 10.0.0.0/8 -j RETURN
    iptables -t mangle -A VPN_BYPASS -d 192.168.0.0/16 -j RETURN
    iptables -t mangle -A VPN_BYPASS -d 172.16.0.0/12 -j RETURN
  '';
in
{
  # 1. Start the OpenVPN Service
  services.openvpn.servers.pia = {
    config = ''
      config /var/lib/nixflix/secrets/pia.ovpn
      # Prevent OpenVPN from overwriting DNS (we want to keep local DNS for Tailscale/Cloudflare)
      pull-filter ignore "dhcp-option DNS"
      # Prevent OpenVPN from dropping the default route for bypassed traffic
      # Instead of 'redirect-gateway def1', we let it set the 0.0.0.0/1 and 128.0.0.0/1 routes
    '';
    autoStart = true;
    updateResolvConf = false; # Don't mess with system DNS
  };

  # 2. Setup the Split Routing rules when the network comes up
  systemd.services.vpn-split-routing = {
    description = "Setup VPN Split Routing for Tailscale and Cloudflare";
    after = [ "network-online.target" "openvpn-pia.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${setupRouting}/bin/setup-vpn-routing";
    };
  };

  # 3. Ensure the cgroup module is loaded for iptables
  boot.kernelModules = [ "xt_cgroup" ];
}
