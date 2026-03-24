return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  -- Lazy.nvim automatically calls the setup for you when you use 'opts'
  opts = {
    ensure_installed = { 
      "lua", 
      "python", 
      "java", 
      "latex", 
      "nix", 
      "markdown", 
      "markdown_inline" 
    },
    highlight = { 
      enable = true,
      -- Use native vim regex for large files or complex LaTeX
      additional_vim_regex_highlighting = { "latex", "markdown" },
    },
    indent = { enable = true },
  },
}
