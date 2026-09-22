{
  config,
  pkgs,
  inputs,
  ...
}:

{

  home.username = "mic";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/mic" else "/home/mic";
  home.stateVersion = "25.11";

  fonts.fontconfig.enable = true;

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };

  # Symlinks for manual configs / large folders
  xdg.configFile = {
    "noctalia".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/noctalia";
    "btop".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/btop";
    "che".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/che";
    "yazi".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/che";
    "drift".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/drift";
    "opencode".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/opencode";
    "nvim".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/nvim";
    "niri".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/niri";
  };

  # Manual symlink for hypr directory
  home.activation.linkHyprConfig = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d "$HOME/.config/hypr" ]; then
      rm -rf "$HOME/.config/hypr"
    fi
    ln -s "$HOME/nixos-dotfiles/config/hypr" "$HOME/.config/hypr"
  '';

  # Manual symlink for niri directory
  home.activation.linkNiriConfig = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d "$HOME/.config/niri" ] && [ ! -L "$HOME/.config/niri" ]; then
      rm -rf "$HOME/.config/niri"
    fi
    ln -sfn "$HOME/nixos-dotfiles/config/niri" "$HOME/.config/niri"
  '';

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
