return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		-- 1. DEFINE YOUR SERVERS (Modern 0.11+ Style)
		-- We define the configuration for each server using vim.lsp.config
		local servers = {
			basedpyright = {},
			texlab = {},
			html = {},
			ts_ls = {},
			lua_ls = {
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
					},
				},
			},
		}

		-- 2. ENABLE SERVERS
		-- This replaces the old lspconfig[name].setup() framework
		for name, config in pairs(servers) do
			config.capabilities = vim.tbl_deep_extend("force", capabilities, config.capabilities or {})
			vim.lsp.enable(name, config)
		end

		-- 3. DIAGNOSTIC CONFIG (Same as before)
		vim.diagnostic.config({
			virtual_text = false, -- Start with it OFF
			signs = true,
			underline = true,
			update_in_insert = false,
			severity_sort = true,
		})

		-- 4. THE TOGGLE: <leader>vn
		vim.keymap.set("n", "<leader>vn", function()
			local config = vim.diagnostic.config().virtual_text
			if config then
				vim.diagnostic.config({ virtual_text = false })
				print("LSP Virtual Text: OFF")
			else
				vim.diagnostic.config({
					virtual_text = { prefix = "●", spacing = 4 },
				})
				print("LSP Virtual Text: ON")
			end
		end, { desc = "Toggle LSP Virtual Text" })

		-- 5. GLOBAL LSP KEYMAPS
		vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP: Hover" })
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "LSP: Go to Definition" })
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP: Code Action" })
	end,
}
