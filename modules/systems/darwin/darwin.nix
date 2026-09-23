{
  config,
  lib,
  pkgs,
  ...
}:

{
  # macOS specific Home Manager settings

  home.packages = with pkgs; [
    moonlight-qt
    iina
    docker-client # CLI client for Docker daemon via Colima
    # Add any other macOS specific CLI tools here
  ];

  # Symlink sketchybar config (disabled when omniwm is enabled)
  xdg.configFile = lib.mkIf (!config.programs.omniwm.enable) {
    "sketchybar".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/sketchybar";
  };
}
