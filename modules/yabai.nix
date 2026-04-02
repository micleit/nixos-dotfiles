{ pkgs, lib, ... }:

let
  createSpacesScript = pkgs.writeShellScript "create_spaces.sh" ''
    #!/bin/sh

    DESIRED_SPACES_PER_DISPLAY=4
    CURRENT_SPACES="$(yabai -m query --displays | jq -r '.[].spaces | @sh')"

    DELTA=0
    while read -r line
    do
      LAST_SPACE="$(echo "''${line##* }")"
      LAST_SPACE=$(($LAST_SPACE+$DELTA))
      EXISTING_SPACE_COUNT="$(echo "$line" | wc -w)"
      MISSING_SPACES=$(($DESIRED_SPACES_PER_DISPLAY - $EXISTING_SPACE_COUNT))
      if [ "$MISSING_SPACES" -gt 0 ]; then
        for i in $(seq 1 $MISSING_SPACES)
        do
          yabai -m space --create "$LAST_SPACE"
          LAST_SPACE=$(($LAST_SPACE+1))
        done
      elif [ "$MISSING_SPACES" -lt 0 ]; then
        for i in $(seq 1 $((-$MISSING_SPACES)))
        do
          yabai -m space --destroy "$LAST_SPACE"
          LAST_SPACE=$(($LAST_SPACE-1))
        done
      fi
      DELTA=$(($DELTA+$MISSING_SPACES))
    done <<< "$CURRENT_SPACES"

    sketchybar --trigger space_change --trigger windows_on_spaces
  '';
in
{
  services.yabai = {
    enable = true;
    # Using the package from nixpkgs
    package = pkgs.yabai;
    enableScriptingAddition = true;

    config = {
      external_bar = "all:33:0";
      mouse_follows_focus = "off";
      focus_follows_mouse = "off";
      window_zoom_persist = "off";
      window_placement = "second_child";
      window_shadow = "float";
      window_opacity = "on";
      window_opacity_duration = "0.2";
      active_window_opacity = "0.98";
      normal_window_opacity = "0.94";
      window_animation_duration = "0.2";
      split_ratio = "0.50";
      auto_balance = "off";
      mouse_modifier = "fn";
      mouse_action1 = "move";
      mouse_action2 = "resize";
      mouse_drop_action = "swap";
      top_padding = 10;
      bottom_padding = 4;
      left_padding = 4;
      right_padding = 4;
      window_gap = 5;
      layout = "bsp";
    };

    extraConfig = ''
      # Unload the macOS WindowManager process
      launchctl unload -F /System/Library/LaunchAgents/com.apple.WindowManager.plist > /dev/null 2>&1 &

      sudo yabai --load-sa
      yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"

      # Signals for Sketchybar
      yabai -m signal --add event=window_focused action="sketchybar --trigger window_focus"
      yabai -m signal --add event=display_added action="sleep 1 && ${createSpacesScript}"
      yabai -m signal --add event=display_removed action="sleep 1 && ${createSpacesScript}"
      yabai -m signal --add event=window_created action="sketchybar --trigger windows_on_spaces"
      yabai -m signal --add event=window_destroyed action="sketchybar --trigger windows_on_spaces"
      yabai -m signal --add event=window_moved action="yabai -m space --balance"

      # Run space creation script on startup
      ${createSpacesScript}

      # Rules
      yabai -m rule --add app="^(LuLu|Calculator|Software Update|Dictionary|System Preferences|System Settings|Photo Booth|Archive Utility|Python|LibreOffice|App Store|Steam|Alfred|Stickies)$" manage=off
      yabai -m rule --add label="Finder" app="^Finder$" title="(Co(py|nnect)|Move|Info|Pref)" manage=off
      yabai -m rule --add label="Safari" app="^Safari$" title="^(General|(Tab|Password|Website|Extension)s|AutoFill|Se(arch|curity)|Privacy|Advance)$" manage=off
      yabai -m rule --add label="About This Mac" app="System Information" title="About This Mac" manage=off
      yabai -m rule --add label="Select file to save to" app="^Inkscape$" title="Select file to save to" manage=off
      yabai -m rule --add app="^kitty$" manage=on

      # Borders (managed separately if using services.jankyborders, but kept here for compatibility)
      borders active_color=0xffebdbb2 inactive_color=0x40ebdbb2 width=6.0 &
    '';
  };

  # Dependency for create_spaces script
  environment.systemPackages = [ pkgs.jq ];
}
