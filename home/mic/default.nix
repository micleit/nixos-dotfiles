{ config, pkgs, inputs, ... }:

{
  imports = [
    ../../modules/shell.nix
    ../../modules/terminal.nix
    ../../modules/shared.nix
    ../../modules/yazi.nix
    ../../modules/nixvim.nix
    ../../modules/caveman.nix
    inputs.nixvim.homeModules.nixvim
  ];

  home.username = "mic";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/mic" else "/home/mic";
  home.stateVersion = "25.11";

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };

  # Symlinks for manual configs / large folders
  xdg.configFile = {
    "hypr".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/hypr";
    "noctalia".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/noctalia";
    "btop".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/btop";
    "yazi".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/yazi";
    "drift".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/drift";
    "tmux".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/tmux";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
