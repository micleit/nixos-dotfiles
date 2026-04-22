{ pkgs, lib, ... }:

{
  config = lib.mkIf pkgs.stdenv.isLinux {
    # Hyprland is enabled at system level (hosts/desktop-nixos/default.nix)
    # We use the symlinked config from ~/nixos-dotfiles/config/hypr instead of declarative module

    home.packages = map (n: pkgs.${n}) [
      "anki"
      "alacritty"
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
      "libreoffice"
      "bitwarden-desktop"
    ];

    home.file.".local/share/icons/macOS-hypr" = {
      source = ../../icons/macOS-hypr;
    };
  };
}
