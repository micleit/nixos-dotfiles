{ inputs, pkgs, ... }:

{
  imports = [ ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };
    users.mic = {
      imports = [
        ../../home/mic/default.nix
        ../../modules/home/shell.nix
        ../../modules/home/terminal.nix
        ../../modules/home/aerc.nix
        ../../modules/home/linux.nix
        ../../modules/home/yazi.nix
        ../../modules/home/helix.nix
        ../../modules/home/caveman.nix
        inputs.nixvim.homeModules.nixvim
      ];
    };
  };

  # Host-specific packages can be declared here or in default.nix
  environment.systemPackages = with pkgs; [ ];
}
