{ pkgs, ... }:

{
  programs.yazi = {
    enable = false;
  };

  home.packages = with pkgs; [
    che
    file
    _7zz
  ];
}
