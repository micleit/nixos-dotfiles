{ pkgs, ... }:

{
  programs.alacritty = {
    enable = pkgs.stdenv.isLinux;
  };

  programs.btop = {
    enable = true;
  };

  home.packages = with pkgs; [
    kitty # Keep kitty as a backup
  ];
}
