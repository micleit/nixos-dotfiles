{ config, pkgs, ... }:

{
  # macOS specific Home Manager settings

  home.packages = with pkgs; [
    # Add any other macOS specific CLI tools here
  ];

  # Symlink existing configs from the repo
  home.file = {
    ".yabairc".source = ../../config/yabai/yabairc;
    ".skhdrc".source = ../../config/skhd/skhdrc;
    ".config/yabai/create_spaces.sh" = {
      source = ../../config/yabai/create_spaces.sh;
      executable = true;
    };
  };

  xdg.configFile = {
    "sketchybar".source = ../../config/sketchybar;
  };
}
