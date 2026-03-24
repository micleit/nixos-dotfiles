return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "black" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				java = { "google-java-format" },
			},
			-- Set global formatting options
			default_format_opts = {
				lsp_fallback = true,
			},
		})

		-- THE KEYBIND: <leader>fd to format with shiftwidth=2
		vim.keymap.set({ "n", "v" }, "<leader>fd", function()
			-- Temporarily set buffer options for the format call
			vim.opt_local.shiftwidth = 4
			vim.opt_local.tabstop = 4
			vim.opt_local.softtabstop = 4

			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range" })
	end,
}
