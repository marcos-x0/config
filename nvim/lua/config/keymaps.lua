-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
local map = vim.keymap.set

-- Key mapping to format the line legth to vim.opt.textwidth
map("n", "<leader>cb", "ggVGgq", { noremap = true, silent = true, desc = "Format buffer to 80 columns" })
-- map(
--   "n",
--   "<leader>r",
--   "<cmd>Telescope oldfiles cwd_only=true<CR>",
--   { desc = "Open recent files in cwd", noremap = true, silent = true }
-- )

-- vim.keymap.set("n", "<leader>ll", require("lsp_lines").toggle, { desc = "Toggle lsp_lines" })

vim.keymap.set("n", "<leader>ll", function()
  ---@diagnostic disable-next-line: undefined-field
  local current = vim.diagnostic.config().virtual_lines

  vim.diagnostic.config({ virtual_lines = not current })
  if not current then
    vim.notify("Lsp lines enabled", vim.log.levels.INFO)
  else
    vim.notify("Lsp lines disabled", vim.log.levels.INFO)
  end
end, { desc = "Toggle lsp_lines" })

vim.keymap.set("n", "<leader>rn", function()
  return ":IncRename " .. vim.fn.expand("<cword>")
end, { expr = true })

map("n", "<leader>e", function()
  vim.cmd("Neotree reveal source=filesystem position=float dir=" .. vim.fn.getcwd())
end)

-- Keybinds to make split navigation easier.
local function navigate_window(direction)
  return function()
    if vim.fn.mode() == "i" then
      -- Handle Insert mode
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true) -- Temporarily exit Insert mode

      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>" .. direction, true, false, true), "n", true) -- Navigate to the target split

      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("a", true, false, true), "n", true) -- Re-enter Insert mode
    else
      -- Handle Normal mode: Navigate directly
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>" .. direction, true, false, true), "n", true)
    end
  end
end

-- Keymaps for navigating splits
map({ "n", "i" }, "<M-Left>", navigate_window("h"), { desc = "Move focus to the left window" })
map({ "n", "i" }, "<M-Right>", navigate_window("l"), { desc = "Move focus to the right window" })
map({ "n", "i" }, "<M-Down>", navigate_window("j"), { desc = "Move focus to the lower window" })
map({ "n", "i" }, "<M-Up>", navigate_window("k"), { desc = "Move focus to the upper window" })

map("x", ">", ">gv", { silent = true, desc = "Indent", noremap = true })
map("x", "<", "< gv", { silent = true, desc = "Indent", noremap = true })

-- vscode like keymaps
-- File Operations
map({ "n", "i", "v" }, "<D-s>", "<cmd>w<CR>", { desc = "Save file" }) -- Command + S: Save
map({ "n", "i", "v" }, "<D-S-s>", "<cmd>wa<CR>", { desc = "Save all files" }) -- Command + Shift + S: Save all
-- map({ 'n', 'i' }, '<D-q>', '<cmd>q<CR>', { desc = 'Quit' }) -- Command + Q: Quit

-- map({ "n", "i" }, "<D-S-q>", "<cmd>q!<CR>", { desc = "Force quit" }) -- Command + Shift + Q: Force quit
-- map({ "n", "i" }, "<D-p>", "<cmd>Telescope find_files<CR>", { desc = "Find files" }) -- Command + P: Find files
--
-- -- Navigation
-- map({ "n", "i", "v" }, "<D-S-f>", "<cmd>Telescope live_grep<CR>", { desc = "Search in workspace" }) -- Command + Shift + F: Search workspace
-- map({ "n", "i", "v" }, "<D-/>", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "Search in file" }) -- Command + /: Search in file

-- Split Management
map({ "n", "i" }, "<M--\\>", "<cmd>vsplit<CR>", { desc = "Split window vertically" }) -- Command + \: Vertical split
map({ "n", "i" }, "<M-->", "<cmd>split<CR>", { desc = "Split window horizontally" }) -- Command + |: Horizontal split

-- Toggling comments (like VSCode's Command + /)
map({ "n", "i" }, "<D-/>", function()
  require("mini.comment").toggle_lines(vim.fn.line("."), vim.fn.line("."))
end, { desc = "Toggle comment" })

map("x", "<D-/>", function()
  -- Get the start and end lines of the visual selection
  local line_start = vim.fn.line("v")
  local line_end = vim.fn.line(".")
  -- Ensure line_start is less than or equal to line_end
  if line_start > line_end then
    line_start, line_end = line_end, line_start
  end
  -- Call the operator for the adjusted line range
  require("mini.comment").toggle_lines(line_start, line_end)
end, { desc = "Toggle comment for selected lines" })

map("x", "<leader>r", "<CMD>SearchReplaceSingleBufferVisualSelection<CR>", { desc = "Replace selected text" })

map("n", "<leader>hp", function()
  require("gitsigns").preview_hunk()
end, { desc = "Preview Git Hunk" })

vim.keymap.set("v", "<leader>cf", function()
  -- Run Conform.nvim formatting
  require("conform").format({
    async = false,
    lsp_fallback = true,
  })

  require("conform").format({
    async = false,
    lsp_fallback = true,
  })

  -- Re-indent selected block
  vim.cmd("normal! =")
end, { desc = "Format with ESLint & Prettier and fix indentation" })

map("n", "<leader>'", function()
  require("fzf-lua").resume()
end, { desc = "Resume fzf-lua" })

-- Primeagen's keymaps

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move highlighted block down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move highlighted block up" })

map("n", "J", "mzJ`z", { desc = "Join lines and maintain cursor position" })
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down half-page and center cursor" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up half-page and center cursor" })
map("n", "n", "nzzzv", { desc = "Next search result and center cursor" })
map("n", "N", "Nzzzv", { desc = "Previous search result and center cursor" })
--map('n', '<leader>zig', '<cmd>LspRestart<cr>', { desc = 'Restart LSP server' })

-- -- greatest remap ever
map("x", "<localleader>p", [["_dP]], { desc = "Paste without overwriting register" })

-- next greatest remap ever
map({ "n", "v" }, "<localleader>y", [["+y]], { desc = "Yank to system clipboard" })
map("n", "<localleader>Y", [["+Y]], { desc = "Yank entire line to system clipboard" })

--map({ "n", "v" }, "<localleader>d", [["_d]], { desc = "Delete to black hole register" })

-- This is going to get me cancelled
map("i", "<C-c>", "<Esc>", { desc = "Map Ctrl-c to escape in insert mode" })

map("n", "<localleader>f", vim.lsp.buf.format, { desc = "Format file with LSP" })

map("n", "<C-k>", "<cmd>cnext<CR>zz", { desc = "Go to next quickfix item and center cursor" })
map("n", "<C-j>", "<cmd>cprev<CR>zz", { desc = "Go to previous quickfix item and center cursor" })
map("n", "<localleader>k", "<cmd>lnext<CR>zz", { desc = "Go to next location list item and center cursor" })
map("n", "<localleader>j", "<cmd>lprev<CR>zz", { desc = "Go to previous location list item and center cursor" })

map(
  "n",
  "<localleader>s",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Replace current word under cursor" }
)
map("n", "<localleader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })

-- map(
--   "n",
--   "<localleader>ee",
--   "oif err != nil {<CR>}<Esc>Oreturn err<Esc>",
--   { desc = "Insert Go error handling" }
-- )
