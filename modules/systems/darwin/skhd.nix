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

      # logout
      # rctrl + shift - f : /usr/bin/osascript -e 'tell app "System Events" to log out'
      # power down 
      # rctrl + shift - ; : /usr/bin/osascript -e 'tell app "System Events" to shut down'
      # reboot
      # rctrl + shift - z : /usr/bin/osascript -e 'tell app "System Events" to restart'
      # sleep 
      hyper - escape : /usr/bin/osascript -e 'tell application "System Events" to sleep'

      # === launch commands ===
      # open ghostty terminal
      rctrl - return : ghostty

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

      # test binding (creates a file to verify execution)
      hyper - t : /usr/bin/touch /tmp/skhd_test
      # second test with a different key
      hyper - z : /usr/bin/touch /tmp/skhd_z_test
    '';
  };
}
