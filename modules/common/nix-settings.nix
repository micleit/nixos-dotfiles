{ ... }:

{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "mic"
    ];
  };

  nixpkgs.config.allowUnfree = true;
}
