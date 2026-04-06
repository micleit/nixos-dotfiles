{ pkgs, ... }:

{
  services.skhd = {
    enable = true;
    skhdConfig = ''
      # === Session defaults ===
      # Define modifiers
      # hyper = cmd + shift + ctrl + alt

      :: default : yabai -m config active_window_border_color 0xE0f5c2e7
      # kickstart yabai 
      ralt - y : yabai --restart-service
      # restart skhd
      ralt + shift - y : skhd --restart-service

      # logout
      # ralt + shift - f : /usr/bin/osascript -e 'tell app "System Events" to log out'
      # power down 
      # ralt + shift - ; : /usr/bin/osascript -e 'tell app "System Events" to shut down'
      # reboot
      # ralt + shift - z : /usr/bin/osascript -e 'tell app "System Events" to restart'
      # sleep 
      hyper - escape : /usr/bin/osascript -e 'tell application "System Events" to sleep'

      # === launch commands ===
      # open ghostty terminal
      ralt - return : ghostty

      # open vscode
      hyper - v : /usr/bin/open -na /Applications/Visual\ Studio\ Code.app

      # open brave
      hyper - b : /usr/bin/open -na "Brave Browser"

      # open finder (opens home folder in new window)
      hyper - f : /usr/bin/open $HOME

      # open yazi in ghostty
      hyper - y : ghostty -e yazi

      # open system preferences
      hyper - s : /usr/bin/open -na '/System/Applications/System Settings.app'

      # test binding (creates a file to verify execution)
      hyper - t : /usr/bin/touch /tmp/skhd_test
      # second test with a different key
      hyper - z : /usr/bin/touch /tmp/skhd_z_test


      # === Navigation ===
      # window focus
      ralt - a : yabai -m window --focus west
      ralt - r : yabai -m window --focus south
      ralt - w : yabai -m window --focus north
      ralt - s : yabai -m window --focus east

      ralt - left : yabai -m window --focus west
      ralt - down : yabai -m window --focus south
      ralt - up : yabai -m window --focus north
      ralt - right : yabai -m window --focus east

      # space focus and creation
      ralt - tab : yabai -m space --focus next || yabai -m space --focus first
      ralt + shift - tab : yabai -m space --focus prev || yabai -m space --focus last
      ralt - x : yabai -m space --focus recent
      ralt - 1 : yabai -m space --focus 1
      ralt - 2 : yabai -m space --focus 2
      ralt - 3 : yabai -m space --focus 3
      ralt - 4 : yabai -m space --focus 4
      ralt - 5 : yabai -m space --focus 5
      ralt - 6 : yabai -m space --focus 6
      ralt - 7 : yabai -m space --focus 7
      ralt - 8 : yabai -m space --focus 8
      ralt - 9 : yabai -m space --focus 9

      # create a space
      ralt + shift - n : yabai -m space --create && yabai -m space --focus last

      # destroy current space
      ralt + shift - d : yabai -m space --destroy

      # === Modification === 
      # Move window relatively
      ralt + shift - a : yabai -m window --warp west
      ralt + shift - r : yabai -m window --warp south
      ralt + shift - w : yabai -m window --warp north
      ralt + shift - s : yabai -m window --warp east

      ralt + shift - left : yabai -m window --warp west
      ralt + shift - down : yabai -m window --warp south
      ralt + shift - up : yabai -m window --warp north
      ralt + shift - right : yabai -m window --warp east

      # --- Send window to space ---
      ralt + shift - x : yabai -m window --space recent
      ralt + shift - 1 : yabai -m window --space 1
      ralt + shift - 2 : yabai -m window --space 2
      ralt + shift - 3 : yabai -m window --space 3
      ralt + shift - 4 : yabai -m window --space 4
      ralt + shift - 5 : yabai -m window --space 5
      ralt + shift - 6 : yabai -m window --space 6
      ralt + shift - 7 : yabai -m window --space 7
      ralt + shift - 8 : yabai -m window --space 8

      # --- Move + focus window to space ---
      ralt + ctrl - m : yabai -m window --space last; yabai -m space --focus last
      ralt + ctrl - p : yabai -m window --space prev; yabai -m space --focus prev
      ralt + ctrl - n : yabai -m window --space next; yabai -m space --focus next
      ralt + ctrl - 1 : yabai -m window --space 1; yabai -m space --focus 1
      ralt + ctrl - 2 : yabai -m window --space 2; yabai -m space --focus 2
      ralt + ctrl - 3 : yabai -m window --space 3; yabai -m space --focus 3
      ralt + ctrl - 4 : yabai -m window --space 4; yabai -m space --focus 4
      ralt + ctrl - 5 : yabai -m window --space 5; yabai -m space --focus 5
      ralt + ctrl - 6 : yabai -m window --space 6; yabai -m space --focus 6
      ralt + ctrl - 7 : yabai -m window --space 7; yabai -m space --focus 7
      ralt + ctrl - 8 : yabai -m window --space 8; yabai -m space --focus 8
      ralt + ctrl - 9 : yabai -m window --space 9; yabai -m space --focus 9
      ralt + ctrl - 0 : yabai -m window --space 0; yabai -m space --focus 0


      # Equalize size of windows
      ralt - e : yabai -m space --balance

      # Enable / Disable gaps in current workspace
      ralt - i : yabai -m space --toggle padding; \
            yabai -m space --toggle gap; \
            yabai -m config external_bar all:30:0; \
            sketchybar --bar hidden=false;

      # Rotate windows clockwise and anticlockwise
      alt - p         : yabai -m space --rotate 270
      shift + alt - p : yabai -m space --rotate 90

      # Rotate on X and Y Axis
      shift + alt - x : yabai -m space --mirror x-axis
      shift + alt - y : yabai -m space --mirror y-axis

      # Set insertion point for focused container
      ralt - v : yabai -m window --insert south
      ralt - h : yabai -m window --insert east

      # Float / Unfloat window
      shift + alt - space : \
          yabai -m window --toggle float; \
          yabai -m window --toggle border

      # Make window native fullscreen
      ctrl + alt - return         : yabai -m window --toggle zoom-fullscreen
      ctrl + alt + shift - return : yabai -m window --toggle native-fullscreen


      # mouse emulation
      hyper - k : /opt/homebrew/bin/cliclick "m:+0,-20" #up
      hyper - j : /opt/homebrew/bin/cliclick "m:+0,+20" #down
      hyper - l : /opt/homebrew/bin/cliclick "m:+20,+0" #right
      hyper - h : /opt/homebrew/bin/cliclick "m:-20,+0" #left

      hyper - m : /opt/homebrew/bin/cliclick ku:cmd,ctrl,alt,shift c:. #release all modifiers and click

      hyper - n : /opt/homebrew/bin/cliclick ku:ctrl rc:.  #right click

      hyper + fn - k : /opt/homebrew/bin/cliclick "m:+0,-40" #up (faster)
      hyper + fn - j : /opt/homebrew/bin/cliclick "m:+0,+40" #down (faster)
      hyper + fn - l : /opt/homebrew/bin/cliclick "m:+40,+0" #right (faster)
      hyper + fn - h : /opt/homebrew/bin/cliclick "m:-40,+0" #left (faster)
    '';
  };
}
