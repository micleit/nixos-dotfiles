{
  description = "nixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    quickshell.url = "github:outfoxxed/quickshell";
    noctalia.url = "github:noctalia-dev/noctalia-shell";
    noctalia-qs.url = "github:noctalia-dev/noctalia-qs";
    nixvim.url = "github:nix-community/nixvim";
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      nixvim,
      darwin,
      ...
    }:
    {
      nixosConfigurations.nixos-btw = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/nixos-btw/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.mic = {
                imports = [
                  ./home/mic/default.nix
                  ./modules/home/desktop-linux.nix
                ];
              };
              extraSpecialArgs = { inherit inputs; };
              backupFileExtension = "backup";
            };
          }
        ];
      };

      darwinConfigurations.mbp-m4 = darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/mbp-m4/default.nix
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.mic = {
                imports = [
                  ./home/mic/default.nix
                  ./modules/home/darwin.nix
                ];
              };
              extraSpecialArgs = { inherit inputs; };
              backupFileExtension = "backup";
            };
          }
        ];
      };

      darwinConfigurations.headless-m1 = darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/headlessm1/default.nix
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.mic = {
                imports = [
                  ./home/mic/default.nix
                  ./modules/home/darwin.nix
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
