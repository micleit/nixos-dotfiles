{
  lib,
  ...
}:

{
  options.homebrew = {
    taps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "felixkratz/formulae" ];
      description = "Homebrew taps to enable";
    };
    casks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Homebrew casks to install";
    };
    brews = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Homebrew formulae to install";
    };
  };

  config = {
    homebrew = {
      enable = true;
      onActivation.cleanup = "uninstall";
      onActivation.autoUpdate = true;
      onActivation.upgrade = true;
    };
  };
}
