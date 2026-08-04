{
  pkgs,
  lib,
  osConfig ? { },
  inputs,
  ...
}:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  config = lib.mkIf pkgs.stdenv.isLinux {
    # Hyprland is enabled at system level (hosts/desktop-nixos/default.nix)
    # We use the symlinked config from ~/nixos-dotfiles/config/hypr instead of declarative module

    programs.noctalia = {
      enable = true;
    };

    home.packages =
      let
        isIpad = (osConfig.networking.hostName or "") == "ipad-nixos";

        terminalAndSystem = [
          "apple-cursor"
          "pavucontrol"
          "wireplumber"
          "hyprpolkitagent"
          "xwayland-satellite"
          "grim"
          "slurp"
          "wl-clipboard"
          "wf-recorder"
          "swaybg"
          "gtk3"
          "hyprshot"
          "xdotool"
        ];

        guiApps = [
          "anki"
          "nautilus"
          "brave"
          "vlc"
          "translate-shell"
          "libreoffice"
          "bitwarden-desktop"
        ];

        targetApps = terminalAndSystem ++ lib.optionals (!isIpad) guiApps;
      in
      map (n: pkgs.${n}) targetApps;
  };
}
