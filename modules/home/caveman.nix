{ pkgs, ... }:

{
  # Caveman: Token-efficient output formatting for Copilot CLI
  # Reduces output by ~75% while maintaining technical accuracy
  # https://github.com/JuliusBrussee/caveman
  #
  # Install via: npx skills add JuliusBrussee/caveman -a github-copilot

  home.packages = with pkgs; [
    nodejs
  ];
}
