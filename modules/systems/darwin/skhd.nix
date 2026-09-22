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
      hyper - f : /usr/bin/open -na "Finder"

      # open che in ghostty
      hyper - y : ghostty -e che

      # open system preferences
      hyper - s : /usr/bin/open -na '/System/Applications/System Settings.app'

      # === OmniWM Navigation ===
      # window focus (r, s, f, t and arrows)
      ralt - r : ${omniwmctl} command focus left
      ralt - s : ${omniwmctl} command focus down
      ralt - f : ${omniwmctl} command focus up
      ralt - t : ${omniwmctl} command focus right

      ralt - left : ${omniwmctl} command focus left
      ralt - down : ${omniwmctl} command focus down
      ralt - up : ${omniwmctl} command focus up
      ralt - right : ${omniwmctl} command focus right

      ralt - tab : ${omniwmctl} command focus previous

      # === OmniWM Window Movement ===
      # move window (r, s, f, t and arrows)
      ralt + shift - r : ${omniwmctl} command move left
      ralt + shift - s : ${omniwmctl} command move down
      ralt + shift - f : ${omniwmctl} command move up
      ralt + shift - t : ${omniwmctl} command move right

      ralt + shift - left : ${omniwmctl} command move left
      ralt + shift - down : ${omniwmctl} command move down
      ralt + shift - up : ${omniwmctl} command move up
      ralt + shift - right : ${omniwmctl} command move right

      # === OmniWM Workspace Management ===
      # switch workspace
      ralt - 1 : ${omniwmctl} command switch-workspace 1
      ralt - 2 : ${omniwmctl} command switch-workspace 2
      ralt - 3 : ${omniwmctl} command switch-workspace 3
      ralt - 4 : ${omniwmctl} command switch-workspace 4
      ralt - 5 : ${omniwmctl} command switch-workspace 5
      ralt - 6 : ${omniwmctl} command switch-workspace 6
      ralt - 7 : ${omniwmctl} command switch-workspace 7
      ralt - 8 : ${omniwmctl} command switch-workspace 8
      ralt - 9 : ${omniwmctl} command switch-workspace 9
      ralt + ctrl - tab : ${omniwmctl} command switch-workspace back-and-forth

      # move window to workspace
      ralt + shift - 1 : ${omniwmctl} command move-to-workspace 1
      ralt + shift - 2 : ${omniwmctl} command move-to-workspace 2
      ralt + shift - 3 : ${omniwmctl} command move-to-workspace 3
      ralt + shift - 4 : ${omniwmctl} command move-to-workspace 4
      ralt + shift - 5 : ${omniwmctl} command move-to-workspace 5
      ralt + shift - 6 : ${omniwmctl} command move-to-workspace 6
      ralt + shift - 7 : ${omniwmctl} command move-to-workspace 7
      ralt + shift - 8 : ${omniwmctl} command move-to-workspace 8
      ralt + shift - 9 : ${omniwmctl} command move-to-workspace 9

      # move column to workspace
      ralt + ctrl + shift - up : ${omniwmctl} command move-column-to-workspace up
      ralt + ctrl + shift - down : ${omniwmctl} command move-column-to-workspace down

      # === OmniWM Layout & Window State ===
      # fullscreen & floating
      ralt + shift - return : ${omniwmctl} command toggle-fullscreen
      ralt + shift - space : ${omniwmctl} command toggle-focused-window-floating

      # column sizing & tabbed toggle
      ralt - 0x2F : ${omniwmctl} command cycle-size forward
      ralt - 0x2B : ${omniwmctl} command cycle-size backward
      ralt + ctrl - f : ${omniwmctl} command toggle-container-full-primary-span
      ralt + ctrl - r : ${omniwmctl} command reset-window-secondary-span
      ralt + ctrl - t : ${omniwmctl} command toggle-column-tabbed
      ralt + shift - b : ${omniwmctl} command balance-sizes

      # layout toggles
      ralt + shift - l : ${omniwmctl} command toggle-workspace-layout
      ralt + shift - o : ${omniwmctl} command toggle-overview

      # monitor focus
      ralt + cmd - tab : ${omniwmctl} command focus-monitor next
      ralt + cmd - 0x32 : ${omniwmctl} command focus-monitor last

      # utilities
      ralt + ctrl - space : ${omniwmctl} command open-command-palette
      ralt + ctrl - m : ${omniwmctl} command open-menu-anywhere
      ralt + ctrl + shift - r : ${omniwmctl} command raise-all-floating-windows
    '';
  };
}
