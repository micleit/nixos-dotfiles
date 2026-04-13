local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

sbar.add("event", "aerospace_workspace_change")

local spaces = {}

for i = 1, 9, 1 do
  local space = sbar.add("item", "space." .. i, {
    icon = {
      font = { family = settings.font.numbers },
      string = i,
      padding_left = 15,
      padding_right = 8,
      color = colors.white,
      highlight_color = colors.red,
    },
    label = {
      padding_right = 20,
      color = colors.grey,
      highlight_color = colors.white,
      font = "sketchybar-app-font:Regular:16.0",
      y_offset = -1,
    },
    padding_right = 1,
    padding_left = 1,
    background = {
      color = colors.bg1,
      border_width = 1,
      height = 26,
      border_color = colors.black,
    }
  })

  spaces[i] = space

  -- Single item bracket for space items to achieve double border on highlight
  local space_bracket = sbar.add("bracket", { space.name }, {
    background = {
      color = colors.transparent,
      border_color = colors.bg2,
      height = 28,
      border_width = 2
    }
  })

  space:subscribe("aerospace_workspace_change", function(env)
    sbar.exec("aerospace list-workspaces --focused", function(focused_workspace)
      local focused = focused_workspace:gsub("%s+", "")
      local selected = focused == tostring(i)
      space:set({
        icon = { highlight = selected, },
        label = { highlight = selected },
        background = { border_color = selected and colors.black or colors.bg2 }
      })
      space_bracket:set({
        background = { border_color = selected and colors.grey or colors.bg2 }
      })
    end)
  end)

  space:subscribe("mouse.clicked", function(env)
    sbar.exec("aerospace workspace " .. i)
  end)
end

local space_window_observer = sbar.add("item", {
  drawing = false,
  updates = true,
})

space_window_observer:subscribe("aerospace_workspace_change", function(env)
  for i = 1, 9, 1 do
    sbar.exec("aerospace list-windows --workspace " .. i .. " --format '%{app-name}'", function(app_names)
      local icon_line = ""
      local no_app = true
      for app in string.gmatch(app_names, "[^\r\n]+") do
        no_app = false
        local lookup = app_icons[app]
        local icon = ((lookup == nil) and app_icons["default"] or lookup)
        if not string.find(icon_line, icon) then
          icon_line = icon_line .. " " .. icon
        end
      end

      if (no_app) then
        icon_line = " —"
      end
      sbar.animate("tanh", 10, function()
        spaces[i]:set({ label = icon_line })
      end)
    end)
  end
end)

-- Initial load
sbar.trigger("aerospace_workspace_change")
