{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.learnharness.nixosModules.default
  ];

  # ============================================================================
  # LEARNHARNESS (Adaptive Teaching Agent & Knowledge Graph)
  # ============================================================================
  services.learnharness = {
    enable = true;
    port = 8383;
    host = "127.0.0.1";
    dataDir = "/var/lib/learnharness/data";
    authFile = "/var/lib/learnharness/auth.json";
    passwordFile = "/var/secrets/learnharness-password";
  };

  # Pre-start script to ensure secrets directory & sample password file exist
  systemd.tmpfiles.rules = [
    "d /var/secrets 0755 root root -"
    "f /var/secrets/learnharness-password 0600 learnharness learnharness -"
  ];
}
