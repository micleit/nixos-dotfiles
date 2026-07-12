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
    spotify
    spicetify-cli
    texliveFull
    neovim-remote
    gemini-cli
    sesh
    opencode
    python3
    python3Packages.pip
    python3Packages.virtualenv
    python3Packages.debugpy
    black
    isort
    ruff
    go
    aerc
    # GUI applications
    obsidian
    sioyek
  ];
}
