{ pkgs, lib, ... }:

{
  config = lib.mkIf pkgs.stdenv.isLinux {
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      extraConfig = "";
    };

    home.packages = map (n: pkgs.${n}) [
      "anki"
      "apple-cursor"
      "nautilus"
      "brave"
      "vlc"
      "geary"
      "seahorse"
      "pavucontrol"
      "wireplumber"
      "quickshell"
      "hyprpolkitagent"
      "xwayland-satellite"
      "grim"
      "slurp"
      "wl-clipboard"
      "tesseract"
      "zbar"
      "translate-shell"
      "wf-recorder"
      "swaybg"
      "gtk3"
      "hyprshot"
      "xdotool"
      "orca-slicer"
      "nicotine-plus"
      "protonup-ng"
      "noctalia-shell"
    ];

    home.file.".local/share/icons/macOS-hypr" = {
      source = ../../icons/macOS-hypr;
    };
  };
}
