return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },

		conform.setup({
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "black" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				-- Java usually uses the LSP (jdtls) for formatting
				java = { "google-java-format" },
			},
			-- Optional: Format on save
			-- format_on_save = {
			--   lsp_fallback = true,
			--   async = false,
			--   timeout_ms = 500,
			-- },
		})

		-- THE KEYBIND: <leader>f to format
		vim.keymap.set({ "n", "v" }, "<leader>fd", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
