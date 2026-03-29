{ pkgs, ... }:

{
  # Common Fonts
  fonts.fontconfig.enable = true;

  # Cross-platform packages
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    curl
    ffmpeg
    gifski
    imagemagick
    texliveFull
    zathura
    gemini-cli
  ];
}
