{
  lib,
  ...
}:

{
  # Override the default sketchybar config with the aerospace-specific one
  xdg.configFile."sketchybar".source = lib.mkForce ../../../config/sketchybar-aerospace;

  # AeroSpace configuration file
  home.file.".config/aerospace/aerospace.toml".text = ''
    # AeroSpace Configuration
    # Reference: https://nikitabobko.github.io/AeroSpace/guide#configuration

    # Layout and gaps
    # sketchybar is already managed as a nix-darwin service, so we don't need a startup command here.

    [gaps]
    inner.horizontal = 5
    inner.vertical = 5
    outer.left = 4
    outer.bottom = 4
    outer.top = 10
    outer.right = 4

    # Sketchybar Integration
    # Trigger when workspace changes
    on-focused-workspace-changed = ['exec-and-forget sketchybar --trigger aerospace_workspace_change']

    [mode.main.binding]
    # Navigation (alt + h/j/k/l or a/r/w/s to match your skhd)
    alt-a = 'focus left'
    alt-r = 'focus down'
    alt-w = 'focus up'
    alt-s = 'focus right'

    alt-h = 'focus left'
    alt-j = 'focus down'
    alt-k = 'focus up'
    alt-l = 'focus right'

    # Move Windows
    alt-shift-a = 'move left'
    alt-shift-r = 'move down'
    alt-shift-w = 'move up'
    alt-shift-s = 'move right'

    alt-shift-h = 'move left'
    alt-shift-j = 'move down'
    alt-shift-k = 'move up'
    alt-shift-l = 'move right'

    # Layouts
    alt-e = 'layout tiles horizontal vertical' # Equalize
    alt-shift-space = 'layout floating tiling' # Toggle float

    # Workspace switching (Match your ralt 1-9)
    alt-1 = 'workspace 1'
    alt-2 = 'workspace 2'
    alt-3 = 'workspace 3'
    alt-4 = 'workspace 4'
    alt-5 = 'workspace 5'
    alt-6 = 'workspace 6'
    alt-7 = 'workspace 7'
    alt-8 = 'workspace 8'
    alt-9 = 'workspace 9'

    # Move window to workspace
    alt-shift-1 = 'move-node-to-workspace 1'
    alt-shift-2 = 'move-node-to-workspace 2'
    alt-shift-3 = 'move-node-to-workspace 3'
    alt-shift-4 = 'move-node-to-workspace 4'
    alt-shift-5 = 'move-node-to-workspace 5'
    alt-shift-6 = 'move-node-to-workspace 6'
    alt-shift-7 = 'move-node-to-workspace 7'
    alt-shift-8 = 'move-node-to-workspace 8'
    alt-shift-9 = 'move-node-to-workspace 9'

    # Fullscreen
    alt-ctrl-enter = 'fullscreen'

    # Launch apps (Matching your ghostty config)
    alt-enter = 'exec-and-forget open -na Ghostty'

    # Rules
    [[on-window-detected]]
    if.app-id = 'com.apple.systempreferences'
    run = 'layout floating'
  '';
}
