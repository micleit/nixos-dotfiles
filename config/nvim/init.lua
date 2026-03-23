-- ========================================================================== --
-- 1. BOOTSTRAP LAZY.NVIM
-- ========================================================================== --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- ========================================================================== --
-- 2. PLUGIN SETUP
-- ========================================================================== --
require("lazy").setup({
  -- Theming (Gruvbox Edition)
  { "ellisonleao/gruvbox.nvim", priority = 1000, config = true },
  
  -- Core
  { "neovim/nvim-lspconfig" },
  { "nvim-lua/plenary.nvim" },

  -- IDE Essentials
  { "nvim-telescope/telescope.nvim" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- Autocompletion & Snippets
  {
    'saghen/blink.cmp',
    version = '*',
    opts = {
      keymap = { preset = 'default' },
      sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
    },
  },
  { "L3MON4D3/LuaSnip", version = "v2.*" },

  -- Language Specifics
  { "lervag/vimtex", lazy = false },
  { "mfussenegger/nvim-jdtls" }, 
  { "MeanderingProgrammer/render-markdown.nvim", opts = {} },

  -- Undo Tree
  { "mbbill/undotree" }
})

-- ========================================================================== --
-- 3. SETTINGS & THEME
-- ========================================================================== --
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.termguicolors = true

-- Apply Gruvbox
vim.o.background = "dark" -- or "light" if you're feeling brave
vim.cmd([[colorscheme gruvbox]])

-- 1. Create a directory for undo files if it doesn't exist
local undodir = vim.fn.expand("~/.local/share/nvim/undo")
if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
end

-- 2. Tell Neovim to use that directory and enable persistent undo
vim.opt.undodir = undodir
vim.opt.undofile = true
-- ========================================================================== --
-- 4. MODERN LSP CONFIG (Nvim 0.11+)
-- ========================================================================== --
if vim.lsp.config then
  vim.lsp.config('basedpyright', { autostart = true })
  vim.lsp.config('marksman', { autostart = true })
  vim.lsp.config('yamlls', { autostart = true })
  vim.lsp.config('texlab', {
    autostart = true,
    settings = {
      texlab = {
        forwardSearch = { executable = 'zathura', args = { '--synctex-forward', '%l:1:%f', '%p' } },
        build = { onSave = true },
      },
    },
  })
end

-- ========================================================================== --
-- 5. MATH SNIPPETS
-- ========================================================================== --
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("tex", {
  s("ff", { t("\\frac{"), i(1), t("}{"), i(2), t("}") }),
  s("dm", { t({ "\\[", "  " }), i(1), t({ "", "\\]" }) }),
  s("mat2", {
    t({ "\\begin{pmatrix}", "  " }), i(1), t(" & "), i(2), t({ " \\\\", "  " }),
    i(3), t(" & "), i(4), t({ "", "\\end{pmatrix}" }),
  }),
})

-- ========================================================================== --
-- 6. KEYMAPS
-- ========================================================================== --
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
-- Toggle Undotree with Space + u
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)

-- VimTeX
vim.g.vimtex_view_method = 'zathura'
