{config, lib, pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    fish
    starship
    ];
  home-manager.users.mic = {
    programs.zoxide.enable = true;
  };
}
