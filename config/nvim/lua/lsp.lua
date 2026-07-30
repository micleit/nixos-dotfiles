local M = {}

function M.setup()
  local capabilities = require("cmp_nvim_lsp").default_capabilities()

  local servers = {
    "basedpyright",
    "lua_ls",
    "texlab",
    "ts_ls",
    "html",
    "nil_ls",
    "nixd",
    "markdown_oxide",
    "ruff",
  }

  for _, lsp in ipairs(servers) do
    vim.lsp.config(lsp, {
      capabilities = capabilities,
    })
    vim.lsp.enable(lsp)
  end
end

return M
