{ config, lib, pkgs, ... }:

{
  services.ollama = {
    enable = true;
    # Required for the M1 to talk to the Optiplex
    host = "0.0.0.0";
    # Since the i7-6700 is older, we use CPU acceleration (default)
    # 16GB RAM is enough for 7B-8B models
  };

  # Open the port in the firewall for local network access
  networking.firewall.allowedTCPPorts = [ 11434 ];
}
