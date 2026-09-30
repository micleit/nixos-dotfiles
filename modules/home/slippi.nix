{
  config,
  inputs,
  ...
}:

{
  imports = [
    inputs.slippi.homeManagerModules.default
  ];

  slippi-launcher = {
    enable = true;
  };

  # The bundled Electron runtime in Slippi Launcher fails to create a Wayland
  # surface on Nvidia when global NIXOS_OZONE_WL=1 is set. Run under XWayland
  # and filter legacy Fontconfig syntax warnings to ensure a clean startup.
  home.file.".local/bin/slippi-launcher" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      exec env NIXOS_OZONE_WL=0 /etc/profiles/per-user/${config.home.username}/bin/slippi-launcher --ozone-platform=x11 "$@" 2> >(grep -v 'Fontconfig warning:' >&2)
    '';
  };

  xdg.desktopEntries.slippi-launcher = {
    name = "Slippi Launcher";
    exec = "env NIXOS_OZONE_WL=0 slippi-launcher --ozone-platform=x11 %U";
    icon = "slippi-launcher";
    comment = "The way to play Melee online";
    categories = [ "Game" ];
    mimeType = [ "application/x-slippi" ];
  };
}
