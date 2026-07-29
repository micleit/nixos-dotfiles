{
  pkgs,
  lib,
  osConfig ? { },
  ...
}:

{
  config = lib.mkIf pkgs.stdenv.isLinux {
    # Hyprland is enabled at system level (hosts/desktop-nixos/default.nix)
    # We use the symlinked config from ~/nixos-dotfiles/config/hypr instead of declarative module

    home.packages =
      let
        isIpad = (osConfig.networking.hostName or "") == "ipad-nixos";

        terminalAndSystem = [
          "alacritty"
          "apple-cursor"
          "pavucontrol"
          "wireplumber"
          "quickshell"
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
          "noctalia-shell"
        ];

        guiApps = [
          "anki"
          "nautilus"
          "brave"
          "vlc"
          "geary"
          "seahorse"
          "tesseract"
          "zbar"
          "translate-shell"
          "orca-slicer"
          "nicotine-plus"
          "protonup-ng"
          "libreoffice"
          "bitwarden-desktop"
          "nextcloud-client"
        ];

        targetApps = terminalAndSystem ++ lib.optionals (!isIpad) guiApps;
      in
      map (n: pkgs.${n}) targetApps;
  };
}
