  { config, pkgs, ...}:
  let 
    dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
    create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
    #NEW CONFIGS GO HERE !!!
    configs = {
      qtile = "qtile";
      nvim = "nvim";
      alacritty = "alacritty";
      mango = "mangowc-btw";
      waybar = "waybar";
      fish = "fish";
      };
  in

  {
  imports = [
	#add imports
  ];
	home.username = "mic";
	home.homeDirectory = "/home/mic";
	programs.git = {
    enable = true;
    settings = {
      user = {
        name = "micah leiterman";
        email = "micah.leiterman@gmail.com";
      };
    };
  };
	home.stateVersion = "25.11";
	programs.fish = {
		enable = true;
		shellAliases = {
			btw = "echo I use nixos, btw";
		};
	};

   xdg.configFile = builtins.mapAttrs (name: subpath: {
    source = create_symlink "${dotfiles}/${subpath}";
    recursive = true;
   })
    configs;

   home.packages = with pkgs; [
	neovim
	ripgrep
	nil
	nixpkgs-fmt
	nodejs
	gcc
  mangowc
  fastfetch
  orca-slicer
  waybar
  wmenu
  wl-clipboard
  kitty
  thunar
  kanata
  eza
   ];
  }
