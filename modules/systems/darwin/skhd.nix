{ pkgs, ... }:

{
  services.skhd = {
    enable = true;
    skhdConfig = ''
      # === Session defaults ===
      # Define modifiers
      # hyper = cmd + shift + ctrl + alt

      # restart skhd
      rctrl + shift - y : launchctl kickstart -k gui/$(id -u)/org.nixos.skhd

      # === launch commands ===
      # open ghostty terminal
      hyper - return : /usr/bin/open -na Ghostty

      # open vscode
      hyper - v : /usr/bin/open -na /Applications/Visual\ Studio\ Code.app

      # open brave
      hyper - b : /usr/bin/open -na "Brave Browser"

      # open finder (opens home folder in new window)
      hyper - f : /usr/bin/open -na "Swift Salamander"

      # open che in ghostty
      hyper - y : ghostty -e che

      # open system preferences
      hyper - s : /usr/bin/open -na '/System/Applications/System Settings.app'
    '';
  };
}
