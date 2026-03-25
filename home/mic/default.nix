{ config, pkgs, inputs, ... }:

{
  imports = [
    ../../modules/home/shell.nix
    ../../modules/home/terminal.nix
    ../../modules/home/desktop.nix
    ../../modules/nixvim.nix # Reuse existing or move to modules/home
    inputs.nixvim.homeModules.nixvim
  ];

  home.username = "mic";
  home.homeDirectory = "/home/mic";
  home.stateVersion = "25.11";

  home.sessionPath = [
    "$HOME/nixos-dotfiles/scripts"
    "$HOME/.local/bin"
  ];

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };

  # Symlinks for manual configs / large folders
  xdg.configFile = {
    "noctalia".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/noctalia";
    "mangowc-btw".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/mangowc-btw";
    "qtile".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/qtile";
    "waybar".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/waybar";
    "kitty".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/kitty";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
