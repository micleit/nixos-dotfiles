{
  description = "nixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    quickshell.url = "github:outfoxxed/quickshell";
    noctalia.url = "github:noctalia-dev/noctalia-shell";
    noctalia-qs.url = "github:noctalia-dev/noctalia-qs";

    home-manager = {
      # Updated to unstable to match your nixpkgs/Noctalia requirements
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs @ { self, nixpkgs, home-manager, ... }: {
    nixosConfigurations.nixos-btw = nixpkgs.lib.nixosSystem {
      # specialArgs allows you to use 'inputs' inside home.nix or configuration.nix
      specialArgs = { inherit inputs; }; 
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.mic = import ./home.nix;
            extraSpecialArgs = { inherit inputs; }; # Passes inputs to home.nix
            backupFileExtension = "backup";
          };
        }
      ];
    };
  };
}
