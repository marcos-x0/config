local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
map({ 'n', 'i' }, '<D-Left>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map({ 'n', 'i' }, '<D-Right>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map({ 'n', 'i' }, '<D-Down>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map({ 'n', 'i' }, '<D-Up>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- vscode like keymaps
-- File Operations
map({ 'n', 'i', 'v' }, '<D-s>', '<cmd>w<CR>', { desc = 'Save file' }) -- Command + S: Save
map({ 'n', 'i', 'v' }, '<D-S-s>', '<cmd>wa<CR>', { desc = 'Save all files' }) -- Command + Shift + S: Save all
-- map({ 'n', 'i' }, '<D-q>', '<cmd>q<CR>', { desc = 'Quit' }) -- Command + Q: Quit
map({ 'n', 'i' }, '<D-S-q>', '<cmd>q!<CR>', { desc = 'Force quit' }) -- Command + Shift + Q: Force quit
map({ 'n', 'i' }, '<D-p>', '<cmd>Telescope find_files<CR>', { desc = 'Find files' }) -- Command + P: Find files

-- Navigation
map({ 'n', 'i', 'v' }, '<D-S-f>', '<cmd>Telescope live_grep<CR>', { desc = 'Search in workspace' }) -- Command + Shift + F: Search workspace
map({ 'n', 'i', 'v' }, '<D-/>', '<cmd>Telescope current_buffer_fuzzy_find<CR>', { desc = 'Search in file' }) -- Command + /: Search in file

-- Split Management
map({ 'n', 'i' }, '<D-S-\\>', '<cmd>vsplit<CR>', { desc = 'Split window vertically' }) -- Command + \: Vertical split
map({ 'n', 'i' }, '<D-S-->', '<cmd>split<CR>', { desc = 'Split window horizontally' }) -- Command + |: Horizontal split

-- Toggling comments (like VSCode's Command + /)
map({ 'n', 'i' }, '<D-/>', function()
  require('mini.comment').toggle_lines(vim.fn.line '.', vim.fn.line '.')
end, { desc = 'Toggle comment' })

map('x', '<D-/>', function()
  -- Call the operator for visual selections
  require('mini.comment').toggle_lines(vim.fn.line 'v', vim.fn.line '.')
end, { desc = 'Toggle comment for selected lines' })

-- Navigation
map({ 'n', 'i' }, '<D-S-f>', '<cmd>Telescope live_grep<CR>', { desc = 'Search in workspace' })
map({ 'n', 'i' }, '<D-p>', '<cmd>Telescope current_buffer_fuzzy_find<CR>', { desc = 'Search in file' })

map('n', '<F2>', ':IncRename ')

map('n', '<leader>e', function()
  vim.cmd('Neotree reveal source=filesystem position=float dir=' .. vim.fn.getcwd())
end)
