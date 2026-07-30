{
  description = "nixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    slippi.url = "github:lytedev/slippi-nix";
    slippi.inputs.nixpkgs.follows = "nixpkgs";
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    copilot-cli.url = "github:scarisey/copilot-cli-flake";
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neomutt-gmail.url = "github:jevy/neomutt-for-gmail";
    nixflix.url = "github:kiriwalawren/nixflix";
    antigravity-nix.url = "github:jacopone/antigravity-nix";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      darwin,
      ...
    }:
    {
      packages =
        nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ]
          (
            system:
            let
              pkgs = nixpkgs.legacyPackages.${system};
            in
            {
              substack-rss = pkgs.callPackage ./pkgs/substack-rss/package.nix { };
              default = self.packages.${system}.substack-rss;
            }
          );

      nixosModules = {
        substack-rss = import ./modules/systems/server/substack-rss.nix;
      };

      nixosConfigurations.desktop-nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/desktop-nixos/default.nix
          ./hosts/desktop-nixos/modules.nix
          home-manager.nixosModules.home-manager
        ];
      };
      nixosConfigurations.latitude = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/latitude/default.nix
          ./hosts/latitude/modules.nix
          home-manager.nixosModules.home-manager
        ];
      };

      nixosConfigurations.acer-nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/acer-nixos/default.nix
          ./hosts/acer-nixos/modules.nix
          home-manager.nixosModules.home-manager
        ];
      };

      nixosConfigurations.optiplex-server = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/optiplex-server/default.nix
          ./hosts/optiplex-server/modules.nix
          home-manager.nixosModules.home-manager
        ];
      };

      nixosConfigurations.new-optiplex = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/new-optiplex/default.nix
          ./hosts/new-optiplex/modules.nix
          home-manager.nixosModules.home-manager
        ];
      };

      nixosConfigurations.ipad-nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/ipad-nixos/default.nix
          ./hosts/ipad-nixos/modules.nix
          home-manager.nixosModules.home-manager
        ];
      };

      darwinConfigurations.mbp-m4 = darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/mbp-m4/default.nix
          ./hosts/mbp-m4/modules.nix
          home-manager.darwinModules.home-manager
        ];
      };

      darwinConfigurations.headless-m1 = darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/headlessm1/default.nix
          ./hosts/headlessm1/modules.nix
          home-manager.darwinModules.home-manager
        ];
      };
    };
}
