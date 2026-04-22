{ pkgs, lib, ... }:

{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    # Global Options (Replaces init.lua core settings)
    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      termguicolors = true;
      undofile = true;
    };

    globals.mapleader = " ";

    # KEYMAPS
    keymaps = [
      {
        mode = [ "n" "v" ];
        key = "<leader>y";
        action = "\"+y";
        options = {
          desc = "Yank to system clipboard";
        };
      }
      {
        mode = "n";
        key = "<leader>lg";
        action = ":LazyGit<CR>"; # Standard command if the plugin is loaded
      }
      # Harpoon 2 Essentials
      {
        mode = "n";
        key = "<leader>a";
        action.__raw = "function() require('harpoon'):list():add() end";
        options.desc = "Harpoon: Add File";
      }
      {
        mode = "n";
        key = "<C-e>";
        action.__raw = "function() require('harpoon').ui:toggle_quick_menu(require('harpoon'):list()) end";
        options.desc = "Harpoon: Quick Menu";
      }
      # Navigating files (Matching your preferred H, J, K, L)
      {
        mode = "n";
        key = "<C-h>";
        action.__raw = "function() require('harpoon'):list():select(1) end";
      }
      {
        mode = "n";
        key = "<C-j>";
        action.__raw = "function() require('harpoon'):list():select(2) end";
      }
      {
        mode = "n";
        key = "<C-k>";
        action.__raw = "function() require('harpoon'):list():select(3) end";
      }
      {
        mode = "n";
        key = "<C-l>";
        action.__raw = "function() require('harpoon'):list():select(4) end";
      }

      # Harpoon + Telescope (Your <leader>fl request)
      {
        mode = "n";
        key = "<leader>fl";
        action.__raw = ''
          function()
            local harpoon = require("harpoon")
            local conf = require("telescope.config").values
            local file_paths = {}
            for _, item in ipairs(harpoon:list().items) do
              table.insert(file_paths, item.value)
            end

            require("telescope.pickers").new({}, {
              prompt_title = "Harpoon Marks",
              finder = require("telescope.finders").new_table({
                results = file_paths,
              }),
              previewer = conf.file_previewer({}),
              sorter = conf.generic_sorter({}),
            }):find()
          end
        '';
        options.desc = "Harpoon List in Telescope";
      }
      {
        mode = [ "n" "v" ];
        key = "<leader>fd";
        action.__raw = ''
          function()
            require("conform").format({
              lsp_fallback = true,
              async = false,
              timeout_ms = 1000,
            })
          end
        '';
        options.desc = "Format file or range";
      }

      # 2. EXPLORER: <leader>cd to open Netrw
      {
        mode = "n";
        key = "<leader>cd";
        action = ":Ex<CR>";
        options.desc = "Open Netrw Explorer";
      }
      {
        mode = "n";
        key = "<leader>ll";
        action = ":VimtexCompile<CR>";
        options.desc = "Vimtex: Toggle Compilation";
      }
      {
        mode = "n";
        key = "<leader>lv";
        action = ":VimtexView<CR>";
        options.desc = "Vimtex: View PDF";
      }
    ];

    # 1. THEME
    colorschemes.gruvbox.enable = true;

    # 2. TREESITTER (Fixed NixOS CLI issues)
    plugins.treesitter = {
      enable = true;
      nixGrammars = true; # Uses Nix to manage the parsers
      settings = {
        highlight.enable = true;
        indent.enable = true;
        ensure_installed = [ "lua" "python" "java" "nix" "latex" "markdown" ];
      };
    };

    # 3. TELESCOPE & HARPOON
    plugins.telescope = {
      enable = true;
      extensions.zoxide.enable = true;
      keymaps = {
        "<leader>ff" = "find_files";
        "<leader>fg" = "live_grep";
      };
    };
    plugins.web-devicons.enable = true;

    plugins.harpoon = {
      enable = true;
      enableTelescope = true; # Built-in integration for your <leader>fl request
    };

    # 4. LSP, COMPLETION & ERRORS
    plugins.lsp = {
      enable = true;
      servers = {
        basedpyright.enable = true;
        lua_ls.enable = true;
        texlab.enable = true;
        ts_ls.enable = true;
        html.enable = true;
        nil_ls.enable = true;
        nixd.enable = true;
        markdown_oxide.enable = true;
      };
    };

    # Completion (Cmp)
    plugins.cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
        sources = [
          { name = "nvim_lsp"; }
          { name = "luasnip"; }
          { name = "buffer"; }
          { name = "path"; }
        ];
        mapping = {
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = "cmp.mapping.select_next_item()";
          "<C-Space>" = "cmp.mapping.complete()";
        };
      };
    };
    plugins.luasnip.enable = true;

    # Formatting (Conform)
    plugins.conform-nvim = {
      enable = true;
      settings = {
        formatters_by_ft = {
          lua = [ "stylua" ];
          python = [ "black" ];
          java = [ "google-java-format" ];
          nix = [ "nixfmt" ];
          markdown = [ "markdown_oxide" ];
        };
      };
    };

    plugins.vimtex = {
      enable = true;

      # Nixvim handles the package, but we set the settings here
      settings = {
        # Use Skim on macOS, Zathura on Linux
        view_method = if pkgs.stdenv.isDarwin then "skim" else "zathura";

        # Skim specific settings for better sync
        view_skim_sync = 1;
        view_skim_activate = 1;

        # Continuous compilation (requires latexmk, which Nixvim pulls in)
        compiler_method = "latexmk";

        # Clean up auxiliary files after compilation
        clean_enabled = true;
      };
    };

    # 5. UI & WHICH-KEY
    plugins.which-key = {
      enable = true;
      settings.win.border = "rounded";
    };

    plugins.lazygit.enable = true;
    plugins.gitsigns.enable = true;



    # 6. CUSTOM LUA LOGIC (The Toggle & Keybinds)
    # This section allows you to inject the specific Lua logic we wrote earlier
    extraConfigLua = ''
      -- The <leader>vn toggle for virtual text
      vim.keymap.set("n", "<leader>vn", function()
        local current = vim.diagnostic.config().virtual_text
        vim.diagnostic.config({ virtual_text = not current })
        print("LSP Virtual Text: " .. (not current and "ON" or "OFF"))
      end, { desc = "Toggle LSP Virtual Text" })

      -- Keybind for your Telescope-Harpoon list
      vim.keymap.set("n", "<leader>fl", ":Telescope harpoon marks<CR>", { desc = "Harpoon List" })
    '';
    extraPackages = with pkgs; [
      lazygit
      nixfmt
      nil
      nixd
      neovim-remote
    ] ++ (lib.optionals stdenv.isLinux [ zathura xdotool ]);

  };
}
