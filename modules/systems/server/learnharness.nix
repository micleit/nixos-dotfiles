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

  # Pre-start script to ensure secrets directory & sample password file exist,
  # and grant learnharness read access to study materials in ~/learnharness
  systemd.tmpfiles.rules = [
    "d /var/secrets 0755 root root -"
    "f /var/secrets/learnharness-password 0600 learnharness learnharness -"
    "z /var/secrets/learnharness-password 0600 learnharness learnharness -"
    "d /var/lib/learnharness/learnharness 0755 learnharness learnharness -"
    "a+ /home/mic - - - - user:learnharness:--x"
    "A+ /home/mic/learnharness - - - - user:learnharness:r-X,default:user:learnharness:r-X"
  ];

  # Allow the service to read ~/learnharness directly and via its own home
  systemd.services.learnharness.serviceConfig = {
    ProtectHome = lib.mkForce "read-only";
    ReadOnlyPaths = [
      "-/home/mic/learnharness"
    ];
    BindReadOnlyPaths = [
      "-/home/mic/learnharness:/var/lib/learnharness/learnharness"
    ];
  };
}
