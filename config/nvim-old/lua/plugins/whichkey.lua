return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		win = {
			border = "rounded",
			title = true,
			title_pos = "center",
			zindex = 1000, -- Matches your autocmd check below
			no_overlap = false,
		},
	},
	config = function(_, opts)
		local wk = require("which-key")
		wk.setup(opts)

		-- Register your group names so they appear in the UI
		wk.add({
			{ "<leader>f", group = "Find/Format" },
			{ "<leader>v", group = "LSP/Diagnostics" },
			{ "<leader>c", group = "Code/Zoxide" },
			{ "<leader>h", group = "Harpoon" },
		})

		-- Custom Autocmd: Reposition window to the right edge and center vertically
		-- This keeps your code visible while looking up commands
		vim.api.nvim_create_autocmd("User", {
			pattern = "WhichKeyOpened",
			callback = function()
				vim.schedule(function()
					local screen_w = vim.o.columns
					local screen_h = vim.o.lines

					for _, win in ipairs(vim.api.nvim_list_wins()) do
						local cfg = vim.api.nvim_win_get_config(win)
						-- Target the WhichKey floating window by its zindex
						if cfg.relative == "editor" and cfg.zindex == 1000 then
							local width = vim.api.nvim_win_get_width(win)
							local height = vim.api.nvim_win_get_height(win)

							vim.api.nvim_win_set_config(win, {
								relative = "editor",
								col = screen_w - width - 2, -- Right-aligned
								row = math.floor((screen_h - height) / 2), -- Vertically centered
							})
						end
					end
				end)
			end,
		})
	end,
}
