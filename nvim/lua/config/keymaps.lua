-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
--

_G.none_ls_enabled = true -- true means it's on, false means it's off

-- Toggle none-ls on/off
vim.keymap.set("n", "<localleader>d", function()
  local null_ls = require("null-ls")
  if _G.none_ls_enabled then
    null_ls.disable({})
    _G.none_ls_enabled = false
    vim.notify("none-ls disabled globally", vim.log.levels.INFO)
  else
    null_ls.enable({})
    _G.none_ls_enabled = true
    vim.notify("none-ls enabled globally", vim.log.levels.INFO)
  end
end, { desc = "Toggle none-ls plugin globally" })

vim.keymap.set({ "n", "i" }, "<M-C-S-b>", function()
  vim.cmd(":Neotree buffers")
  local buffer_num = vim.fn.input("Enter buffer number: ")
  if buffer_num ~= "" then
    vim.cmd("buffer " .. buffer_num)
  end
end, { desc = "Open Neo-tree Buffers and prompt for a buffer number to switch to" })

vim.keymap.set({ "n", "i" }, "<M-C-b>", function()
  local buffer_num = vim.fn.input("Enter buffer number: ")
  if buffer_num ~= "" then
    vim.cmd("buffer " .. buffer_num)
  end
end, { desc = "switch to buffer number" })

-- Keybindings to navigate between Neovim splits
-- for some reason mapping M-C-j doesn't work, but arrow does
-- vim.keymap.del("n", "<C-h>")
-- vim.keymap.del("n", "<C-j>")
-- vim.keymap.del("n", "<C-k>")
-- vim.keymap.del("n", "<C-l>")
-- vim.keymap.set("n", "<M-C>h", "<C-w>h", { desc = "Go to Left Window", remap = true })
-- vim.keymap.set("n", "<M-C>j", "<C-w>j", { desc = "Go to Lower Window", remap = true })
-- vim.keymap.set("n", "<M-C>k", "<C-w>k", { desc = "Go to Upper Window", remap = true })
-- vim.keymap.set("n", "<M-C>l", "<C-w>l", { desc = "Go to Right Window", remap = true })
--

-- Setup wezterm.nvim plugin

-- Function to check if we're at the edge in the specified direction
local function is_at_edge(direction)
  local current_win = vim.fn.winnr() -- Get current window number

  if direction == "Right" then
    -- If there's no window to the right, we're at the edge
    return current_win == vim.fn.winnr("l")
  elseif direction == "Left" then
    -- If there's no window to the left, we're at the edge
    return current_win == vim.fn.winnr("h")
  elseif direction == "Up" then
    -- If there's no window above, we're at the edge
    return current_win == vim.fn.winnr("k")
  elseif direction == "Down" then
    -- If there's no window below, we're at the edge
    return current_win == vim.fn.winnr("j")
  end

  return false -- This is at the edge in the specified direction
end

-- Function to handle moving between Neovim and WezTerm panes
local function move_in_direction(direction)
  if is_at_edge(direction) then
    -- Move to the respective WezTerm pane if at the edge
    require("wezterm").switch_pane.direction(direction)
    -- require("wezterm").activate_pane_direction(direction)
  else
    -- Otherwise, move within Neovim using <C-w> navigation
    if direction == "Right" then
      vim.cmd("wincmd l")
    elseif direction == "Left" then
      vim.cmd("wincmd h")
    elseif direction == "Up" then
      vim.cmd("wincmd k")
    elseif direction == "Down" then
      vim.cmd("wincmd j")
    end
  end
end

-- Key mappings for all directions using <M-C-Arrow> bindings
local opts = { noremap = true, silent = true, desc = "Move between splits or wezterm panes" }

-- Right movement
vim.keymap.set({ "n", "i" }, "<M-C-Right>", function()
  move_in_direction("Right")
end, { noremap = true, silent = true, desc = "Move to the split to the right" })

-- Left movement
vim.keymap.set({ "n", "i" }, "<M-C-Left>", function()
  move_in_direction("Left")
end, { noremap = true, silent = true, desc = "Move to the split to the left" })

-- Up movement
vim.keymap.set({ "n", "i" }, "<M-C-Up>", function()
  move_in_direction("Up")
end, { noremap = true, silent = true, desc = "Move to the split above" })

-- Down movement
vim.keymap.set({ "n", "i" }, "<M-C-Down>", function()
  move_in_direction("Down")
end, { noremap = true, silent = true, desc = "Move to the split below" })

-- vim.keymap.set("n", "<M-C-Left>", "<C-w>h", { desc = "Go to Left Window", remap = true })
-- vim.keymap.set("n", "<M-C-Down>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
-- vim.keymap.set("n", "<M-C-Up>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
-- vim.keymap.set("n", "<M-C-Right>", "<C-w>l", { desc = "Go to Right Window", remap = true })
--
-- vim.keymap.set("n", "<M-C>h", "<C-w>h", { remap = true, silent = true })
-- vim.keymap.set("n", "<M-C>j", "<C-w>j", { remap = true, silent = true })
-- vim.keymap.set("n", "<M-C>k", "<C-w>k", { remap = true, silent = true })
-- vim.keymap.set("n", "<M-C>l", "<C-w>l", { remap = true, silent = true })
--
--
-- Keybindings to split Neovim windows
vim.keymap.set("n", "<M-C-->", ":vsplit<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<M-C-\\>", ":split<CR>", { noremap = true, silent = true })

-- Key mapping to format the line legth to vim.opt.textwidth
vim.keymap.set("n", "<leader>cb", "ggVGgq", { noremap = true, silent = true, desc = "Format buffer to 80 columns" })
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
