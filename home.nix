  { config, pkgs, inputs,...}:
  let 
    dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
    create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
    #NEW CONFIGS GO HERE !!!
    configs = {
      qtile = "qtile";
      # nvim = "nvim";
      alacritty = "alacritty";
      waybar = "waybar";
      kitty = "kitty";
      hypr = "hypr";
      noctalia = "noctalia";
      btop = "btop";
      yazi = "yazi";
      };
  in

  {
  imports = [
  ];

  home.sessionPath = [
    "$HOME/nixos-dotfiles/scripts"
    "$HOME/.local/bin"
  ];

	home.username = "mic";
	home.homeDirectory = "/home/mic";
  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      "\\\${HOME}/.steam/root/compatibilitytools.d";
  };

	programs.git = {
    enable = true;
    settings = {
      user = {
        name = "micah leiterman";
        email = "micah.leiterman@gmail.com";
      };
    };
  };

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

    home.file.".local/share/icons/macOS-hypr" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/icons/macOS-hypr";
    };

   home.packages = with pkgs; [
	# neovim
	ripgrep
	nil
	nixpkgs-fmt
	nodejs
	gcc
  fastfetch
  orca-slicer
  waybar
  wmenu
  wl-clipboard
  kitty
  nautilus
  kanata
  brave
  nicotine-plus
  protonup-ng
  noctalia-shell
  btop
  gemini-cli
   ];
	home.stateVersion = "25.11";
  }
