{ pkgs, ... }:

{
  programs.yazi = {
    enable = false;
  };

  home.packages = with pkgs; [
    che

    # Yazi/Che File Viewing Dependencies
    ffmpeg
    ffmpegthumbnailer
    imagemagick
    poppler-utils
    exiftool
    glow
    pandoc
    chafa
    fontforge
    file
    _7zz
  ];
}
