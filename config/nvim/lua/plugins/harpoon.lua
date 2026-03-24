return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup()

		-- 1. DEFINE THE TELESCOPE PICKER FUNCTION
		local function toggle_telescope(harpoon_files)
			local conf = require("telescope.config").values
			local file_paths = {}
			for _, item in ipairs(harpoon_files.items) do
				table.insert(file_paths, item.value)
			end

			require("telescope.pickers")
				.new({}, {
					prompt_title = "Harpoon Marks",
					finder = require("telescope.finders").new_table({
						results = file_paths,
					}),
					previewer = conf.file_previewer({}),
					sorter = conf.generic_sorter({}),
				})
				:find()
		end

		-- 2. THE KEYBINDS
		-- <leader>a: Add file
		vim.keymap.set("n", "<leader>a", function()
			harpoon:list():add()
		end, { desc = "Harpoon: Add file" })

		-- <leader>fl: Open list in Telescope
		vim.keymap.set("n", "<leader>fl", function()
			toggle_telescope(harpoon:list())
		end, { desc = "Harpoon: Open List in Telescope" })

		-- Keep the native <C-e> menu if you still want the quick-edit mode
		vim.keymap.set("n", "<C-e>", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "Harpoon: Native Menu" })
	end,
}
