{ config, pkgs, ... }:

{
  # macOS specific Home Manager settings

  home.packages = with pkgs; [
    moonlight-qt
    # Add any other macOS specific CLI tools here
  ];

  # Symlink existing configs from the repo
  home.file = { };

  xdg.configFile = {
    "sketchybar".source = ../../config/sketchybar;
  };
}
