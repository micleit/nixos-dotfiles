{
  description = "nixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    quickshell.url = "github:outfoxxed/quickshell";
    noctalia.url = "github:noctalia-dev/noctalia-shell";
    noctalia-qs.url = "github:noctalia-dev/noctalia-qs";
    copilot-cli.url = "github:scarisey/copilot-cli-flake";
    nixvim.url = "github:nix-community/nixvim";
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    inputs@{ self
    , nixpkgs
    , home-manager
    , nixvim
    , darwin
    , ...
    }:
    {
      nixosConfigurations.desktop-nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/desktop-nixos/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.mic = {
                imports = [
                  ./home/mic/default.nix
                  ./modules/linux/desktop-linux.nix
                  ./modules/gui-apps.nix
                ];
              };
              extraSpecialArgs = { inherit inputs; };
              backupFileExtension = "backup";
            };
          }
        ];
      };

      nixosConfigurations.acer-nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/acer-nixos/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.mic = {
                imports = [
                  ./home/mic/default.nix
                ];
              };
              extraSpecialArgs = { inherit inputs; };
              backupFileExtension = "backup";
            };
          }
        ];
      };

      nixosConfigurations.optiplex-server = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/optiplex-server/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.mic = {
                imports = [
                  ./home/mic/default.nix
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
                  ./modules/gui-apps.nix
                  ./modules/darwin/darwin.nix
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
                  ./modules/darwin/darwin.nix
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
