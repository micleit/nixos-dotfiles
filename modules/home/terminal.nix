{ pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
  };

  programs.btop = {
    enable = true;
  };

  home.packages = with pkgs; [
    kitty # Keep kitty as a backup
  ];
}
