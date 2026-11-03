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
    lazygit
    speedtest-cli
  ];
}
