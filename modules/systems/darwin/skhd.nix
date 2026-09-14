{ pkgs, ... }:

let
  omniwmctl = "${pkgs.omniwm}/bin/omniwmctl";
in
{
  services.skhd = {
    enable = true;
    skhdConfig = ''
      # === Modifiers ===
      # hyper = cmd + shift + ctrl + alt

      # restart skhd
      rcmd + shift - y : launchctl kill SIGTERM gui/$(id -u)/org.nixos.skhd

      # sleep
      hyper - escape : /usr/bin/osascript -e 'tell application "System Events" to sleep'

      # === Launch Commands ===
      # open ghostty terminal
      rcmd - return : /usr/bin/open -na Ghostty

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

      # === OmniWM Navigation ===
      # window focus (s, d, e, f and arrows)
      rcmd - s : ${omniwmctl} command focus left
      rcmd - d : ${omniwmctl} command focus down
      rcmd - e : ${omniwmctl} command focus up
      rcmd - f : ${omniwmctl} command focus right

      rcmd - left : ${omniwmctl} command focus left
      rcmd - down : ${omniwmctl} command focus down
      rcmd - up : ${omniwmctl} command focus up
      rcmd - right : ${omniwmctl} command focus right

      rcmd - tab : ${omniwmctl} command focus previous

      # === OmniWM Window Movement ===
      # move window
      rcmd + shift - s : ${omniwmctl} command move left
      rcmd + shift - d : ${omniwmctl} command move down
      rcmd + shift - e : ${omniwmctl} command move up
      rcmd + shift - f : ${omniwmctl} command move right

      rcmd + shift - left : ${omniwmctl} command move left
      rcmd + shift - down : ${omniwmctl} command move down
      rcmd + shift - up : ${omniwmctl} command move up
      rcmd + shift - right : ${omniwmctl} command move right

      # === OmniWM Workspace Management ===
      # switch workspace
      rcmd - 1 : ${omniwmctl} command switch-workspace 1
      rcmd - 2 : ${omniwmctl} command switch-workspace 2
      rcmd - 3 : ${omniwmctl} command switch-workspace 3
      rcmd - 4 : ${omniwmctl} command switch-workspace 4
      rcmd - 5 : ${omniwmctl} command switch-workspace 5
      rcmd - 6 : ${omniwmctl} command switch-workspace 6
      rcmd - 7 : ${omniwmctl} command switch-workspace 7
      rcmd - 8 : ${omniwmctl} command switch-workspace 8
      rcmd - 9 : ${omniwmctl} command switch-workspace 9
      rcmd + ctrl - tab : ${omniwmctl} command switch-workspace back-and-forth

      # move window to workspace
      rcmd + shift - 1 : ${omniwmctl} command move-to-workspace 1
      rcmd + shift - 2 : ${omniwmctl} command move-to-workspace 2
      rcmd + shift - 3 : ${omniwmctl} command move-to-workspace 3
      rcmd + shift - 4 : ${omniwmctl} command move-to-workspace 4
      rcmd + shift - 5 : ${omniwmctl} command move-to-workspace 5
      rcmd + shift - 6 : ${omniwmctl} command move-to-workspace 6
      rcmd + shift - 7 : ${omniwmctl} command move-to-workspace 7
      rcmd + shift - 8 : ${omniwmctl} command move-to-workspace 8
      rcmd + shift - 9 : ${omniwmctl} command move-to-workspace 9

      # move column to workspace
      rcmd + ctrl + shift - up : ${omniwmctl} command move-column-to-workspace up
      rcmd + ctrl + shift - down : ${omniwmctl} command move-column-to-workspace down

      # === OmniWM Layout & Window State ===
      # fullscreen & floating
      rcmd + shift - return : ${omniwmctl} command toggle-fullscreen
      rcmd + shift - space : ${omniwmctl} command toggle-focused-window-floating

      # column sizing & tabbed toggle
      rcmd - period : ${omniwmctl} command cycle-size forward
      rcmd - comma : ${omniwmctl} command cycle-size backward
      rcmd + ctrl - f : ${omniwmctl} command toggle-container-full-primary-span
      rcmd + ctrl - r : ${omniwmctl} command reset-window-secondary-span
      rcmd - t : ${omniwmctl} command toggle-column-tabbed
      rcmd + shift - b : ${omniwmctl} command balance-sizes

      # layout toggles
      rcmd + shift - l : ${omniwmctl} command toggle-workspace-layout
      rcmd + shift - o : ${omniwmctl} command toggle-overview

      # monitor focus
      rcmd + alt - tab : ${omniwmctl} command focus-monitor next
      rcmd + alt - 0x32 : ${omniwmctl} command focus-monitor last

      # utilities
      rcmd + ctrl - space : ${omniwmctl} command open-command-palette
      rcmd + ctrl - m : ${omniwmctl} command open-menu-anywhere
      rcmd + shift - r : ${omniwmctl} command raise-all-floating-windows
    '';
  };
}
