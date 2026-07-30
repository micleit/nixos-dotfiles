local plugins = {
  -- Theme
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      vim.cmd("colorscheme gruvbox")
    end,
  },

  -- Icons
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require("nvim-web-devicons").setup({})
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.install").prefer_git = true
      require("nvim-treesitter").setup({
        highlight = { enable = true },
        indent = { enable = true },
        ensure_installed = {
          "lua",
          "python",
          "java",
          "nix",
          "latex",
          "markdown",
        },
      })
    end,
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "jvgrootveld/telescope-zoxide",
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({})
      telescope.load_extension("zoxide")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
    end,
  },

  -- Harpoon
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("harpoon"):setup({})
    end,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("lsp").setup()
    end,
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<C-Space>"] = cmp.mapping.complete(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- Formatting
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "black" },
          java = { "google-java-format" },
          nix = { "nixfmt" },
          markdown = { "markdown_oxide" },
        },
      })
    end,
  },


  -- Debugging (DAP)
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "mfussenegger/nvim-dap-python",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()
      require("dap-python").setup("python3")

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },

  -- Vimtex
  {
    "lervag/vimtex",
    tag = "v2.17",
    lazy = false,
    init = function()
      vim.g.vimtex_view_method = "sioyek"
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_clean_enabled = 1
    end,
  },

  -- Which-Key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    config = function()
      local wk = require("which-key")
      wk.setup({
        win = {
          border = "rounded",
        },
      })
      wk.add({
        { "m", group = "surround" },
        { "ma", desc = "Add Surround" },
        { "md", desc = "Delete Surround" },
        { "mr", desc = "Replace Surround" },
        { "<leader>b", group = "buffer" },
        { "<leader>x", group = "diagnostics" },
        { "<leader>q", group = "session/quit" },
      })
    end,
  },

  -- LazyGit
  {
    "kdheepak/lazygit.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- Surround (Helix keybindings)
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      -- Disable default mappings
      vim.g.nvim_surround_no_mappings = true

      require("nvim-surround").setup({})

      -- Configure custom mappings manually (v4 way)
      vim.keymap.set("n", "ma", "<Plug>(nvim-surround-normal)", { desc = "Add surround" })
      vim.keymap.set("n", "maa", "<Plug>(nvim-surround-normal-cur)", { desc = "Add surround to current line" })
      vim.keymap.set("n", "mA", "<Plug>(nvim-surround-normal-line)", { desc = "Add surround on new lines" })
      vim.keymap.set("n", "mAA", "<Plug>(nvim-surround-normal-cur-line)", { desc = "Add surround to current line on new lines" })
      vim.keymap.set("x", "ma", "<Plug>(nvim-surround-visual)", { desc = "Add surround (visual)" })
      vim.keymap.set("x", "mA", "<Plug>(nvim-surround-visual-line)", { desc = "Add surround on new lines (visual)" })
      vim.keymap.set("n", "md", "<Plug>(nvim-surround-delete)", { desc = "Delete surround" })
      vim.keymap.set("n", "mr", "<Plug>(nvim-surround-change)", { desc = "Replace surround" })
    end,
  },

  -- Surround UI (Visual prompts for surround)
  {
    "roobert/surround-ui.nvim",
    dependencies = {
      "kylechui/nvim-surround",
      "folke/which-key.nvim",
    },
    config = function()
      require("surround-ui").setup({
        root_key = "m",
      })
    end,
  },

  -- Oil (File Explorer)
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup({})
    end,
  },

  -- Trouble (Diagnostics Panel)
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("trouble").setup({})
    end,
  },


  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  -- Autotag
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    config = function()
      require("nvim-ts-autotag").setup({})
    end,
  },

  -- Lualine (Statusline)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "gruvbox",
        },
      })
    end,
  },

  -- Bufferline (Buffer Tabs)
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({})
    end,
  },

  -- Nvim-Notify & Noice (Notification & Command Popups)
  {
    "rcarriga/nvim-notify",
    config = function()
      local notify = require("notify")
      notify.setup({
        background_colour = "#000000",
      })
      vim.notify = notify
    end,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = false,
        },
      })
    end,
  },

  -- Persistence (Session Management)
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    config = function()
      require("persistence").setup({})
    end,
  },

  -- Indent-Blankline (Indentation scope lines)
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "VeryLazy",
    config = function()
      require("ibl").setup({})
    end,
  },

  -- Dressing (Input & Select UI popup styling)
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    config = function()
      require("dressing").setup({})
    end,
  },

  -- Flash (High speed jumping)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    config = function()
      require("flash").setup({})
    end,
  },
}

require("lazy").setup(plugins)
