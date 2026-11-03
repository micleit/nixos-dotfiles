{
  pkgs,
  ...
}:

{
  imports = [
    ./tmux.nix
  ];

  programs.btop = {
    enable = true;
  };

  home.packages = with pkgs; [
    ghostty.terminfo
    lazygit
    speedtest-cli
  ];
}
