{config, lib, pkgs, ...}:

{
users.users.mic.shell = pkgs.fish;

  environment.systemPackages = with pkgs; [
    fish
    starship
    ];
  home-manager.users.mic = {
    programs.zoxide.enable = true;
  };
  programs.fish.enable = true;
}
