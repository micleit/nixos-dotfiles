{ pkgs, ... }:

{
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    shellWrapperName = "y";
  };

  home.packages = with pkgs; [
    # Yazi File Viewing Dependencies
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
