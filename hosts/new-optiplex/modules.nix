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
        ../../home/mic/server.nix
        ../../modules/home/shell-server.nix
        ../../modules/home/terminal-server.nix
        ../../modules/home/yazi-server.nix
        ../../modules/home/neovim-server.nix
      ];
    };
  };

  # Host-specific packages can be declared here or in default.nix
  environment.systemPackages = with pkgs; [
    inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli
  ];
}
