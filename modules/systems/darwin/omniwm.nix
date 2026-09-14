{
  pkgs,
  lib,
  ...
}:

{
  home-manager.users.mic =
    { config, ... }:
    {
      programs.omniwm = {
        enable = true;
        package = pkgs.omniwm;
        launchd = {
          enable = true;
          keepAlive = true;
        };
        settings = { };
      };

      # Symlink to mutable tracked config in repo so OmniWM GUI can write to it
      xdg.configFile."omniwm/settings.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/omniwm/settings.toml";
    };

  # CLI and scripting dependencies
  environment.systemPackages = [
    pkgs.omniwm
    pkgs.jq
  ];
}
