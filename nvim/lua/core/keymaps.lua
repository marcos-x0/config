local map = vim.keymap.set
-- local opts = { noremap = true, silent = true }

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

local function navigate_window(direction)
  return function()
    if vim.fn.mode() == 'i' then
      -- Handle Insert mode
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true) -- Temporarily exit Insert mode

      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-w>' .. direction, true, false, true), 'n', true) -- Navigate to the target split

      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('a', true, false, true), 'n', true) -- Re-enter Insert mode
    else
      -- Handle Normal mode: Navigate directly
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-w>' .. direction, true, false, true), 'n', true)
    end
  end
end

-- Keymaps for navigating splits
vim.keymap.set({ 'n', 'i' }, '<D-Left>', navigate_window 'h', { desc = 'Move focus to the left window' })
vim.keymap.set({ 'n', 'i' }, '<D-Right>', navigate_window 'l', { desc = 'Move focus to the right window' })
vim.keymap.set({ 'n', 'i' }, '<D-Down>', navigate_window 'j', { desc = 'Move focus to the lower window' })
vim.keymap.set({ 'n', 'i' }, '<D-Up>', navigate_window 'k', { desc = 'Move focus to the upper window' })
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

-- map('n', '<leader>e', function()
--   vim.cmd('Neotree reveal source=filesystem position=float dir=' .. vim.fn.getcwd())
-- end)

-- load the session for the current directory
map('n', '<leader>qs', function()
  require('persistence').load()
end)

-- select a session to load
map('n', '<leader>qS', function()
  require('persistence').select()
end)

-- load the last session
map('n', '<leader>ql', function()
  require('persistence').load { last = true }
end)

-- stop Persistence => session won't be saved on exit
map('n', '<leader>qd', function()
  require('persistence').stop()
end)

map('n', '<leader>qq', '<cmd>qa<cr>', { desc = 'Save and Quit All' })

-- Normal mode mapping to replace the word under the cursor
map('n', '<leader>rw', '<CMD>SearchReplaceSingleBufferCWord<CR>', { desc = 'Replace word under cursor' })

-- Visual mode mapping to replace the selected text
map('x', '<leader>r', '<CMD>SearchReplaceSingleBufferVisualSelection<CR>', { desc = 'Replace selected text' })
