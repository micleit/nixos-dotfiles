{ pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {
      monitor = ",1920x1080@144,0x0, 1";

      "$terminal" = "alacritty";
      "$fileManager" = "nautilus";
      "$browser" = "brave";
      "$ipc" = "noctalia-shell ipc call";
      "$mainMod" = "mod5"; # Right Alt

      exec-once = [
        "noctalia-shell"
        "systemctl --user start hyprpolkitagent"
      ];

      env = [
        "HYPRCURSOR_THEME,macOS-hypr"
        "HYPRCURSOR_SIZE,28"
        "XCURSOR_SIZE,24"
      ];

      cursor = {
        no_hardware_cursors = true;
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 3;
        resize_on_border = false;
        allow_tearing = false;
        layout = "dwindle";
        "col.active_border" = "rgb(ffb2b8)"; # Inlined from noctalia-colors.conf for now
        "col.inactive_border" = "rgb(131313)";
      };

      decoration = {
        rounding = 20;
        active_opacity = 1.0;
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
        blur = {
          enabled = true;
          size = 8;
          passes = 3;
          new_optimizations = true;
          xray = true;
        };
      };

      animations = {
        enabled = "yes";
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 5, myBezier, popin 80%"
          "windowsOut, 1, 5, myBezier, popin 80%"
          "layers, 1, 5, myBezier, fade"
          "layersIn, 1, 5, myBezier, fade"
          "layersOut, 1, 5, myBezier, fade"
          "fade, 1, 5, myBezier"
          "workspaces, 1, 5, myBezier, slide"
          "specialWorkspaceIn, 1, 5, myBezier, fade"
          "specialWorkspaceOut, 1, 5, myBezier, fade"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      input = {
        kb_layout = "us,us";
        kb_variant = "colemak_dh,";
        kb_options = "grp:alt_shift_toggle";
        follow_mouse = 1;
        sensitivity = -0.6;
        touchpad = {
          natural_scroll = false;
        };
      };

      bind = [
        "$mainMod, return, exec, $terminal"
        "$mainMod, q, killactive,"
        "$mainMod, b, exec, $browser"
        "$mainMod, f, exec, $fileManager"
        "$mainMod, V, togglefloating,"
        "$mainMod, m, exec, command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"
        "mod5 Shift, F, fullscreen,"
        "$mainMod, y, exec, alacritty --title \"yazi-float\" -e fish -c \"y\""
        "mod5, SPACE, exec, $ipc launcher toggle"
        "mod5, comma, exec, $ipc controlCenter toggle"
        "mod5, equal, exec, $ipc settings toggle"
        "mod5, period, exec, $ipc wallpaper toggle"
        "$mainMod, a, movefocus, l"
        "$mainMod, s, movefocus, r"
        "$mainMod, w, movefocus, u"
        "$mainMod, r, movefocus, d"
        "$mainMod shift, a, movewindow, l"
        "$mainMod shift, s, movewindow, r"
        "$mainMod shift, w, movewindow, u"
        "$mainMod shift, r, movewindow, d"
      ] ++ (
        # Workspaces
        builtins.concatLists (builtins.genList (i:
          let ws = i + 1;
          in [
            "$mainMod, ${toString (if ws == 10 then 0 else ws)}, workspace, ${toString ws}"
            "$mainMod SHIFT, ${toString (if ws == 10 then 0 else ws)}, movetoworkspacesilent, ${toString ws}"
          ]
        ) 10)
      );

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      bindel = [
        ", XF86AudioRaiseVolume, exec, $ipc volume increase"
        ", XF86AudioLowerVolume, exec, $ipc volume decrease"
        ", XF86MonBrightnessUp, exec, $ipc brightness increase"
        ", XF86MonBrightnessDown, exec, $ipc brightness decrease"
      ];

      bindl = [
        ", XF86AudioMute, exec, $ipc volume muteOutput"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      windowrulev2 = [
        "opacity 0.85 0.75, class:(Alacritty)"
        "opacity 0.95 0.9, class:(brave-browser)"
        "opacity 0.85 0.8, class:(steam)"
        "float, title:(yazi-float)"
        "size 1000 700, title:(yazi-float)"
        "center, title:(yazi-float)"
        "suppressmaximize, class:.*"
        "no_focus, xwayland:1, floating:1, class:^$, title:^$"
        "move 20 monitor_h-120, class:(hyprland-run)"
        "float, class:(hyprland-run)"
      ];

      layerrule = [
        "blur, match:namespace noctalia-background-.*$"
        "ignore_alpha 0.5, match:namespace noctalia-background-.*$"
        "blur_popups, match:namespace noctalia-background-.*$"
      ];
    };
  };

  # Waybar
  programs.waybar = {
    enable = true;
    # settings = ... (from config.jsonc)
    # style = ... (from style.css)
  };

  # Fonts
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    apple-cursor
    nautilus
    brave
    vlc
    geary
    seahorse
    pavucontrol
    wireplumber
    quickshell
    hyprpolkitagent
    xwayland-satellite
    grim
    slurp
    swaybg
    gtk3
    hyprshot
    zathura
    texliveFull
    xdotool
    orca-slicer
    nicotine-plus
    protonup-ng
    noctalia-shell
    gemini-cli
  ];

  # Icons / Cursors
  home.file.".local/share/icons/macOS-hypr" = {
    source = ../../icons/macOS-hypr; # Point to the right location
  };
}
