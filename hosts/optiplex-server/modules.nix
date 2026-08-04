{ inputs, pkgs, ... }:

{
  imports = [
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };
    users.mic = {
      imports = [
        ../../modules/systems/linux/desktop-linux.nix
        ../../home/mic/default.nix
        ../../modules/home/shell.nix
        ../../modules/home/terminal.nix
        ../../modules/home/linux.nix
        ../../modules/home/yazi.nix
        ../../modules/home/neovim.nix
        ../../modules/home/caveman.nix
      ];
    };
  };

  # Host-specific packages can be declared here or in default.nix
  environment.systemPackages = with pkgs; [
        inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli
  ];
}
