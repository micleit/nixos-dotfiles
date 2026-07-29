{
  pkgs,
  inputs,
  osConfig ? { },
  lib,
  ...
}:

{
  # Common Fonts
  fonts.fontconfig.enable = true;

  # Cross-platform packages
  home.packages =
    with pkgs;
    let
      isIpad = (osConfig.networking.hostName or "") == "ipad-nixos";

      terminalAndCLI = [
        nerd-fonts.jetbrains-mono
        curl
        ffmpeg
        gifski
        imagemagick
        texliveFull
        neovim-remote
        gemini-cli
        inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli
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
      ];

      guiApps = [
        spotify
        spicetify-cli
        obsidian
        sioyek
      ];
    in
    terminalAndCLI ++ lib.optionals (!isIpad) guiApps;
}
