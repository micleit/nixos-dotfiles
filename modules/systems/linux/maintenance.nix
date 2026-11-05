{ config
, lib
, pkgs
, ...
}:

{
  # ============================================================================
  # NIX STORE MAINTENANCE & GARBAGE COLLECTION (SYSTEM-LEVEL)
  # ============================================================================
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Automatically deduplicate identical files in the Nix store
  nix.optimise.automatic = true;

  # Limit systemd-boot generations kept in the /boot EFI partition
  boot.loader.systemd-boot.configurationLimit = lib.mkDefault 10;
}
