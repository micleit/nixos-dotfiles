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
      # right_command is mapped to ctrl + alt in Karabiner
      # holding right_command + shift produces ctrl + alt + shift (meh)

      # restart skhd
      ctrl + alt + shift - y : launchctl kill SIGTERM gui/$(id -u)/org.nixos.skhd

      # sleep
      hyper - escape : /usr/bin/osascript -e 'tell application "System Events" to sleep'

      # === Launch Commands ===
      # open ghostty terminal (right_command + return)
      ctrl + alt - return : /usr/bin/open -na Ghostty

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

      # === OmniWM Navigation (right_command + key) ===
      # window focus (s, d, e, f and arrows)
      ctrl + alt - s : ${omniwmctl} command focus left
      ctrl + alt - d : ${omniwmctl} command focus down
      ctrl + alt - e : ${omniwmctl} command focus up
      ctrl + alt - f : ${omniwmctl} command focus right

      ctrl + alt - left : ${omniwmctl} command focus left
      ctrl + alt - down : ${omniwmctl} command focus down
      ctrl + alt - up : ${omniwmctl} command focus up
      ctrl + alt - right : ${omniwmctl} command focus right

      ctrl + alt - tab : ${omniwmctl} command focus previous

      # === OmniWM Window Movement (right_command + shift + key) ===
      # move window
      ctrl + alt + shift - s : ${omniwmctl} command move left
      ctrl + alt + shift - d : ${omniwmctl} command move down
      ctrl + alt + shift - e : ${omniwmctl} command move up
      ctrl + alt + shift - f : ${omniwmctl} command move right

      ctrl + alt + shift - left : ${omniwmctl} command move left
      ctrl + alt + shift - down : ${omniwmctl} command move down
      ctrl + alt + shift - up : ${omniwmctl} command move up
      ctrl + alt + shift - right : ${omniwmctl} command move right

      # === OmniWM Workspace Management ===
      # switch workspace (right_command + 1..9)
      ctrl + alt - 1 : ${omniwmctl} command switch-workspace 1
      ctrl + alt - 2 : ${omniwmctl} command switch-workspace 2
      ctrl + alt - 3 : ${omniwmctl} command switch-workspace 3
      ctrl + alt - 4 : ${omniwmctl} command switch-workspace 4
      ctrl + alt - 5 : ${omniwmctl} command switch-workspace 5
      ctrl + alt - 6 : ${omniwmctl} command switch-workspace 6
      ctrl + alt - 7 : ${omniwmctl} command switch-workspace 7
      ctrl + alt - 8 : ${omniwmctl} command switch-workspace 8
      ctrl + alt - 9 : ${omniwmctl} command switch-workspace 9
      ctrl + alt + cmd - tab : ${omniwmctl} command switch-workspace back-and-forth

      # move window to workspace (right_command + shift + 1..9)
      ctrl + alt + shift - 1 : ${omniwmctl} command move-to-workspace 1
      ctrl + alt + shift - 2 : ${omniwmctl} command move-to-workspace 2
      ctrl + alt + shift - 3 : ${omniwmctl} command move-to-workspace 3
      ctrl + alt + shift - 4 : ${omniwmctl} command move-to-workspace 4
      ctrl + alt + shift - 5 : ${omniwmctl} command move-to-workspace 5
      ctrl + alt + shift - 6 : ${omniwmctl} command move-to-workspace 6
      ctrl + alt + shift - 7 : ${omniwmctl} command move-to-workspace 7
      ctrl + alt + shift - 8 : ${omniwmctl} command move-to-workspace 8
      ctrl + alt + shift - 9 : ${omniwmctl} command move-to-workspace 9

      # move column to workspace
      ctrl + alt + shift - up : ${omniwmctl} command move-column-to-workspace up
      ctrl + alt + shift - down : ${omniwmctl} command move-column-to-workspace down

      # === OmniWM Layout & Window State ===
      # fullscreen & floating
      ctrl + alt + shift - return : ${omniwmctl} command toggle-fullscreen
      ctrl + alt + shift - space : ${omniwmctl} command toggle-focused-window-floating

      # column sizing & tabbed toggle
      ctrl + alt - period : ${omniwmctl} command cycle-size forward
      ctrl + alt - comma : ${omniwmctl} command cycle-size backward
      ctrl + alt + shift - f : ${omniwmctl} command toggle-container-full-primary-span
      ctrl + alt + shift - r : ${omniwmctl} command reset-window-secondary-span
      ctrl + alt - t : ${omniwmctl} command toggle-column-tabbed
      ctrl + alt + shift - b : ${omniwmctl} command balance-sizes

      # layout toggles
      ctrl + alt + shift - l : ${omniwmctl} command toggle-workspace-layout
      ctrl + alt + shift - o : ${omniwmctl} command toggle-overview

      # monitor focus
      ctrl + alt + cmd - tab : ${omniwmctl} command focus-monitor next
      ctrl + alt + cmd - 0x32 : ${omniwmctl} command focus-monitor last

      # utilities
      ctrl + alt - space : ${omniwmctl} command open-command-palette
      ctrl + alt - m : ${omniwmctl} command open-menu-anywhere
    '';
  };
}
