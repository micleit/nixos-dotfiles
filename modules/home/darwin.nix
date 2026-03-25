{ config, ... }:

{
  # macOS specific Home Manager settings
  home.homeDirectory = "/Users/mic";

  # Symlink existing configs
  xdg.configFile = {
    "yabai/yabairc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/yabai/yabairc";
    "skhd/skhdrc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/skhd/skhdrc";
  };
}
