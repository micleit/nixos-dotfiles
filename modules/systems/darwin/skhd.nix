{ pkgs, ... }:

{
  services.skhd = {
    enable = true;
    skhdConfig = ''
      # === Modifiers ===
      # hyper = cmd + shift + ctrl + alt

      # restart skhd
      hyper + shift - y : launchctl kill SIGTERM gui/$(id -u)/org.nixos.skhd

      # sleep
      hyper - escape : /usr/bin/osascript -e 'tell application "System Events" to sleep'

      # === Launch Commands ===
      # open ghostty terminal
      ralt - return : /usr/bin/open -na Ghostty

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
