-- Hyprland Lua Configuration migrated from hyprland.conf

---------------------
---- MY PROGRAMS ----
---------------------
local browser     = "brave"
local fileManager = "nautilus"
local ipc         = "noctalia msg"
local mainMod     = "MOD1"
local terminal    = "ghostty"

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd DISPLAY HYPRLAND_INSTANCE_SIGNATURE WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE && systemctl --user stop hyprland-session.target && systemctl --user start hyprland-session.target")
    hl.exec_cmd("noctalia")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("HYPRCURSOR_THEME", "macOS-hypr")
hl.env("HYPRCURSOR_SIZE", "28")
hl.env("XCURSOR_SIZE", "24")

------------------
---- MONITORS ----
------------------
-- Optiplex Server display (Samsung 1080p @ 60Hz via HDMI)
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@60",
    position = "0x0",
    scale    = 1,
})
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
    general = {
        allow_tearing    = false,
        border_size      = 3,
        col = {
            active_border   = "rgb(ffb2b8)",
            inactive_border = "rgb(131313)",
        },
        gaps_in          = 5,
        gaps_out         = 10,
        layout           = "dwindle",
        resize_on_border = false,
    },

    decoration = {
        active_opacity = 1.0,
        rounding       = 20,
        rounding_power = 2,

        blur = {
            enabled           = true,
            new_optimizations = true,
            passes            = 3,
            size              = 8,
            xray              = true,
        },

        shadow = {
            color        = "rgba(1a1a1aee)",
            enabled      = true,
            range        = 4,
            render_power = 3,
        },
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    cursor = {
        no_hardware_cursors = true,
    },

    animations = {
        enabled = true,
    },
})

-- Animations
hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })

hl.animation({ leaf = "windows",            enabled = true, speed = 5, bezier = "myBezier", style = "popin 80%" })
hl.animation({ leaf = "windowsOut",         enabled = true, speed = 5, bezier = "myBezier", style = "popin 80%" })
hl.animation({ leaf = "layers",             enabled = true, speed = 5, bezier = "myBezier", style = "fade" })
hl.animation({ leaf = "layersIn",           enabled = true, speed = 5, bezier = "myBezier", style = "fade" })
hl.animation({ leaf = "layersOut",          enabled = true, speed = 5, bezier = "myBezier", style = "fade" })
hl.animation({ leaf = "fade",               enabled = true, speed = 5, bezier = "myBezier" })
hl.animation({ leaf = "workspaces",         enabled = true, speed = 5, bezier = "myBezier", style = "slide" })
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true, speed = 5, bezier = "myBezier", style = "fade" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 5, bezier = "myBezier", style = "fade" })

---------------
---- INPUT ----
---------------
hl.config({
    input = {
        emulate_discrete_scroll = false,
        follow_mouse            = 1,
        kb_layout               = "us,us,us",
        kb_options              = "altwin:swap_lalt_lwin, lv3:ralt_alt",
        kb_variant              = "colemak_dh,,dvorak",
        sensitivity             = -0.6,

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.device({
    name       = "hl-virtual-keyboard-.lan-mouse-wrapped",
    kb_layout  = "us,us,us",
    kb_variant = "colemak_dh,,dvorak",
    kb_options = "altwin:swap_lalt_lwin, lv3:ralt_alt",
})

---------------------
---- KEYBINDINGS ----
---------------------
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",      hl.dsp.window.close())
hl.bind(mainMod .. " + T",      hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V",      hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + H",      hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + BackSpace", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))

-- Noctalia shortcuts
hl.bind(mainMod .. " + space",  hl.dsp.exec_cmd(ipc .. " panel-toggle launcher"))
hl.bind(mainMod .. " + comma",  hl.dsp.exec_cmd(ipc .. " panel-toggle control-center"))
hl.bind(mainMod .. " + equal",  hl.dsp.exec_cmd(ipc .. " settings-toggle"))
hl.bind(mainMod .. " + period", hl.dsp.exec_cmd(ipc .. " panel-toggle wallpaper"))

-- Toggle animations
hl.bind(mainMod .. " + SHIFT + SUPER + A", function()
    local disabled = (hl.get_config("animations.enabled") == false)
    if disabled then
        hl.config({ animations = { enabled = true } })
    else
        hl.config({ animations = { enabled = false } })
    end
end)

-- Focus movement
hl.bind(mainMod .. " + A", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + D", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + W", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + S", hl.dsp.focus({ direction = "down" }))

-- Window movement
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ direction = "down" }))

-- Workspaces 1-10
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Media and Volume keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. " volume-up"),       { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. " volume-down"),     { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd(ipc .. " brightness-up"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd(ipc .. " brightness-down"), { locked = true, repeating = true })

hl.bind("XF86AudioMute",  hl.dsp.exec_cmd(ipc .. " volume-mute"),   { locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),        { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),    { locked = true })

-- Mouse binds
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
hl.layer_rule({
    match        = { namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$" },
    blur         = true,
    ignore_alpha = 0.5,
    blur_popups  = true,
})

hl.window_rule({ match = { class = "com.mitchellh.ghostty" }, opacity = "0.75 0.65" })
hl.window_rule({ match = { class = "Alacritty" },             opacity = "0.85 0.75" })
hl.window_rule({ match = { class = "brave-browser" },          opacity = "0.95 0.9" })
hl.window_rule({ match = { class = "steam" },                  opacity = "0.85 0.8" })
hl.window_rule({ match = { class = "obsidian" },               opacity = "0.7 0.5" })

hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name     = "fix-xwayland-drags",
    match    = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})

--------------------------
---- NOCTALIA COLORS  ----
--------------------------
local function load_noctalia_theme()
    local ok = pcall(function()
        require("noctalia").apply_theme()
    end)
    if ok then return end

    -- Fallback: parse noctalia.conf if noctalia.lua is not generated yet
    local conf_path = os.getenv("HOME") .. "/.config/hypr/noctalia.conf"
    local f = io.open(conf_path, "r")
    if not f then return end
    local colors = {}
    for line in f:lines() do
        local var, val = line:match("^%s*%$([%w_]+)%s*=%s*(.+)$")
        if var and val then
            colors[var] = val:gsub("%s+$", "")
        end
    end
    f:close()

    if colors.primary or colors.surface then
        hl.config({
            general = {
                col = {
                    active_border   = colors.primary or "rgb(ffb2b8)",
                    inactive_border = colors.surface or "rgb(131313)",
                },
            },
        })
    end
    if colors.secondary or colors.surface or colors.error then
        hl.config({
            group = {
                col = {
                    border_active          = colors.secondary or "rgb(e1c1a4)",
                    border_inactive        = colors.surface or "rgb(131313)",
                    border_locked_active   = colors.error or "rgb(ffb4ab)",
                    border_locked_inactive = colors.surface or "rgb(131313)",
                },
                groupbar = {
                    col = {
                        active          = colors.secondary or "rgb(e1c1a4)",
                        inactive        = colors.surface or "rgb(131313)",
                        locked_active   = colors.error or "rgb(ffb4ab)",
                        locked_inactive = colors.surface or "rgb(131313)",
                    },
                },
            },
        })
    end
end

load_noctalia_theme()
