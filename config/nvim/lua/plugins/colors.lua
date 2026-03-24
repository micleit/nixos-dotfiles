return {
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000, -- High priority to ensure it loads before other plugins
    config = function()
      -- Configure Gruvbox options before loading the colorscheme
      require("gruvbox").setup({
        terminal_colors = true, -- add neovim terminal colors
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
          strings = true,
          emphasis = true,
          comments = true,
          operators = false,
          folds = true,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        invert_intent_guides = false,
        inverse = true, -- invert background for search, accent colors
        contrast = "medium", -- can be "hard", "medium", "soft"
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = false,
      })

      -- Set the background (CS/Math major tip: 'dark' is easier on the eyes for late nights)
      vim.o.background = "dark"
      
      -- Load the colorscheme
      vim.cmd([[colorscheme gruvbox]])
    end,
  },
}
