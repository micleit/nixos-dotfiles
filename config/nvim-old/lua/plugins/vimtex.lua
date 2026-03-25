return {
  "lervag/vimtex",
  lazy = false, -- Vimtex handles its own loading; best not to lazy-load
  config = function()
    -- PDF Viewer settings
    vim.g.vimtex_view_method = "zathura"
    -- SyncTeX settings (Forward/Backward search)
    -- This allows Neovim to tell Zathura where the cursor is
    vim.g.vimtex_view_general_viewer = "zathura"
    -- Automatic compilation on save
    vim.g.vimtex_compiler_method = "latexmk"
    -- Clean up auxiliary files (log, aux, etc.) on exit
    vim.g.vimtex_clean_enabled = 1

    -- Keybinds for your Math workflow
    vim.keymap.set("n", "<leader>ll", "<cmd>VimtexCompile<CR>", { desc = "LaTeX: Toggle Compile" })
    vim.keymap.set("n", "<leader>lv", "<cmd>VimtexView<CR>", { desc = "LaTeX: View PDF" })
    vim.keymap.set("n", "<leader>lc", "<cmd>VimtexClean<CR>", { desc = "LaTeX: Clean Aux Files" })
    vim.keymap.set("n", "<leader>le", "<cmd>VimtexErrors<CR>", { desc = "LaTeX: View Errors" })
  end,
}
