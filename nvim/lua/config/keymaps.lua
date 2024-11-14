-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
vim.keymap.set("n", "<M-C-Left>", "<C-w>h", { desc = "Go to Left Window", remap = true })
vim.keymap.set("n", "<M-C-Down>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
vim.keymap.set("n", "<M-C-Up>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
vim.keymap.set("n", "<M-C-Right>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- -- Key mapping to format the line legth to vim.opt.textwidth
vim.keymap.set("n", "<leader>cb", "ggVGgq", { noremap = true, silent = true, desc = "Format buffer to 80 columns" })
vim.keymap.set(
  "n",
  "<leader>r",
  "<cmd>Telescope oldfiles cwd_only=true<CR>",
  { desc = "Open recent files in cwd", noremap = true, silent = true }
)

vim.keymap.set("n", "<leader>e", function()
  vim.cmd("Neotree reveal source=filesystem position=float dir=" .. vim.fn.getcwd())
end)

--
-- vim.keymap.set("n", "<leader>e", function()
--   vim.cwd("Neotree reveal source=filesystem position=float dir=" .. vim.fn.getcwd())
-- end, { desc = "Open Neo-tree at project root and reveal currwnt buffer file" })

-- Primeagen's keymaps

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move highlighted block down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move highlighted block up" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and maintain cursor position" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down half-page and center cursor" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up half-page and center cursor" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result and center cursor" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result and center cursor" })
--vim.keymap.set('n', '<leader>zig', '<cmd>LspRestart<cr>', { desc = 'Restart LSP server' })

-- -- greatest remap ever
vim.keymap.set("x", "<localleader>p", [["_dP]], { desc = "Paste without overwriting register" })

-- next greatest remap ever
vim.keymap.set({ "n", "v" }, "<localleader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<localleader>Y", [["+Y]], { desc = "Yank entire line to system clipboard" })

--vim.keymap.set({ "n", "v" }, "<localleader>d", [["_d]], { desc = "Delete to black hole register" })

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Map Ctrl-c to escape in insert mode" })

vim.keymap.set("n", "<localleader>f", vim.lsp.buf.format, { desc = "Format file with LSP" })

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz", { desc = "Go to next quickfix item and center cursor" })
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz", { desc = "Go to previous quickfix item and center cursor" })
vim.keymap.set("n", "<localleader>k", "<cmd>lnext<CR>zz", { desc = "Go to next location list item and center cursor" })
vim.keymap.set(
  "n",
  "<localleader>j",
  "<cmd>lprev<CR>zz",
  { desc = "Go to previous location list item and center cursor" }
)

vim.keymap.set(
  "n",
  "<localleader>s",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Replace current word under cursor" }
)
vim.keymap.set("n", "<localleader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })

-- vim.keymap.set(
--   "n",
--   "<localleader>ee",
--   "oif err != nil {<CR>}<Esc>Oreturn err<Esc>",
--   { desc = "Insert Go error handling" }
-- )
