-- KEYMAPS

-- Yank to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })

-- LazyGit
vim.keymap.set("n", "<leader>lg", ":LazyGit<CR>", { desc = "Open LazyGit" })

-- Harpoon 2 Essentials
vim.keymap.set("n", "<leader>a", function()
  local harpoon = require("harpoon")
  harpoon:list():add()
  local file = vim.fn.expand("%:t")
  vim.notify("Harpooned: " .. (file ~= "" and file or "[No Name]"), vim.log.levels.INFO, { title = "Harpoon" })
end, { desc = "Harpoon: Add File" })

vim.keymap.set("n", "<C-e>", function()
  require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
end, { desc = "Harpoon: Quick Menu" })

-- Harpoon List in Telescope
vim.keymap.set("n", "<leader>fl", function()
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
end, { desc = "Harpoon List in Telescope" })

-- Format file or range (Conform)
vim.keymap.set({ "n", "v" }, "<leader>fd", function()
  require("conform").format({
    lsp_fallback = true,
    async = false,
    timeout_ms = 1000,
  })
end, { desc = "Format file or range" })

-- EXPLORER: leader cd to open Netrw
vim.keymap.set("n", "<leader>cd", "<CMD>Oil<CR>", { desc = "Open Netrw Explorer" })

-- Vimtex compilation
vim.keymap.set("n", "<leader>ll", ":VimtexCompile<CR>", { desc = "Vimtex: Toggle Compilation" })
vim.keymap.set("n", "<leader>lv", ":VimtexView<CR>", { desc = "Vimtex: View PDF" })

-- Toggle diagnostic virtual text
vim.keymap.set("n", "<leader>vn", function()
  local current = vim.diagnostic.config().virtual_text
  vim.diagnostic.config({ virtual_text = not current })
  print("LSP Virtual Text: " .. (not current and "ON" or "OFF"))
end, { desc = "Toggle LSP Virtual Text" })

-- DAP Debugger keymaps (will be lazy-loaded or loaded when dap is available)
vim.keymap.set("n", "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "DAP: Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dc", function() require("dap").continue() end, { desc = "DAP: Continue" })
vim.keymap.set("n", "<leader>do", function() require("dap").step_over() end, { desc = "DAP: Step Over" })
vim.keymap.set("n", "<leader>di", function() require("dap").step_into() end, { desc = "DAP: Step Into" })
vim.keymap.set("n", "<leader>du", function() require("dap").step_out() end, { desc = "DAP: Step Out" })
vim.keymap.set("n", "<leader>dr", function() require("dap").run_last() end, { desc = "DAP: Run Last" })
vim.keymap.set("n", "<leader>dq", function() require("dap").terminate() end, { desc = "DAP: Terminate" })
vim.keymap.set("n", "<leader>dt", function() require("dapui").toggle() end, { desc = "DAP: Toggle UI" })

-- Oil (File Explorer)
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory in Oil" })

-- Trouble (Diagnostics Panel)
vim.keymap.set("n", "<leader>xx", "<CMD>Trouble diagnostics toggle<CR>", { desc = "Trouble: Toggle Diagnostics" })
vim.keymap.set("n", "<leader>xw", "<CMD>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Trouble: Buffer Diagnostics" })

-- Aerial (Outline Viewer)
vim.keymap.set("n", "<leader>o", "<CMD>AerialToggle!<CR>", { desc = "Aerial: Toggle Outline" })

-- Bufferline cycling
vim.keymap.set("n", "[b", "<CMD>BufferLineCyclePrev<CR>", { desc = "Cycle to previous buffer" })
vim.keymap.set("n", "]b", "<CMD>BufferLineCycleNext<CR>", { desc = "Cycle to next buffer" })
vim.keymap.set("n", "<leader>bd", "<CMD>bdelete<CR>", { desc = "Delete current buffer" })

-- Persistence (Session Management)
vim.keymap.set("n", "<leader>qs", function() require("persistence").load() end, { desc = "Session: Load directory session" })
vim.keymap.set("n", "<leader>ql", function() require("persistence").load({ last = true }) end, { desc = "Session: Load last session" })
vim.keymap.set("n", "<leader>qd", function() require("persistence").stop() end, { desc = "Session: Stop saving on exit" })

-- Flash (Motion Navigation)
vim.keymap.set({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash Jump" })
vim.keymap.set({ "n", "x", "o" }, "S", function() require("flash").treesitter() end, { desc = "Flash Treesitter" })
vim.keymap.set({ "o" }, "r", function() require("flash").remote() end, { desc = "Flash Remote" })

-- Trigger Which-Key popup manually for the surround "m" prefix
vim.keymap.set("n", "m", function()
  require("which-key").show({ keys = "m" })
end, { desc = "Surround Menu" })

vim.keymap.set("x", "m", function()
  require("which-key").show({ keys = "m", mode = "x" })
end, { desc = "Surround Menu" })


