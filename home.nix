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
      git = "git";
    };
  in

  {
  imports = [
    ./git.nix
  ];
	home.username = "mic";
	home.homeDirectory = "/home/mic";
	programs.git.enable = true;
	home.stateVersion = "25.11";
	programs.bash = {
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
   ];
  }
