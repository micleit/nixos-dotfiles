{
	description = "nixOS";
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";	
		home-manager = {
			url = "github:nix-community/home-manager/release-25.11";
			inputs.nixpkgs.follows = "nixpkgs";
		};
    mangowc = {
      url = "github:DreamMaoMao/mangowc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
	};
  	outputs = {self, nixpkgs, home-manager, mangowc, ...}: {
		nixosConfigurations.nixos-btw = nixpkgs.lib.nixosSystem {
			system = "aarch-64-linux";
			modules = [
				./configuration.nix
        mangowc.nixosModules.mango
        {
          programs.mango.enable = true;
        }
				home-manager.nixosModules.home-manager
				{
					home-manager = {
						useGlobalPkgs = true;
						useUserPackages = true;
						users.mic = import ./home.nix;
						backupFileExtension = "backup";
					};
				}
			];
		};
	}; 
}
