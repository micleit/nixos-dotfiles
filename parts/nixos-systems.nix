{
  config,
  inputs,
  lib,
  self,
  ...
}:
{
  flake.nixosConfigurations = {
    desktop-nixos = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        "${self}/hosts/desktop-nixos/default.nix"
        inputs.slippi.nixosModules.default
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.mic = {
              imports = [
                "${self}/home/mic/default.nix"
                "${self}/modules/linux/desktop-linux.nix"
                "${self}/modules/gui-apps.nix"
              ];
            };
            extraSpecialArgs = { inherit inputs; };
            backupFileExtension = "backup";
          };
        }
      ];
    };

    acer-nixos = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        "${self}/hosts/acer-nixos/default.nix"
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.mic = {
              imports = [
                "${self}/home/mic/default.nix"
              ];
            };
            extraSpecialArgs = { inherit inputs; };
            backupFileExtension = "backup";
          };
        }
      ];
    };

    optiplex-server = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        "${self}/hosts/optiplex-server/default.nix"
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.mic = {
              imports = [
                "${self}/home/mic/default.nix"
              ];
            };
            extraSpecialArgs = { inherit inputs; };
            backupFileExtension = "backup";
          };
        }
      ];
    };
  };
}
