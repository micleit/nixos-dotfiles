{
  config,
  inputs,
  lib,
  self,
  ...
}:
{
  flake.darwinConfigurations = {
    mbp-m4 = inputs.darwin.lib.darwinSystem {
      specialArgs = { inherit inputs; };
      modules = [
        "${self}/hosts/mbp-m4/default.nix"
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.mic = {
              imports = [
                "${self}/home/mic/default.nix"
                "${self}/modules/gui-apps.nix"
                "${self}/modules/darwin/darwin.nix"
              ];
            };
            extraSpecialArgs = { inherit inputs; };
            backupFileExtension = "backup";
          };
        }
      ];
    };

    headless-m1 = inputs.darwin.lib.darwinSystem {
      specialArgs = { inherit inputs; };
      modules = [
        "${self}/hosts/headlessm1/default.nix"
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.mic = {
              imports = [
                "${self}/home/mic/default.nix"
                "${self}/modules/darwin/darwin.nix"
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
