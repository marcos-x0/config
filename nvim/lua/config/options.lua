-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.maplocalleader = ","
vim.opt.colorcolumn = "80"
vim.opt.textwidth = 79
vim.g.snacks_animate = false

vim.opt.relativenumber = false
vim.opt.number = true

vim.g.root_spec = { ".git", "lsp", "cwd" }
-- Undercurl
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

-- Enable spell check
vim.opt.spell = false
vim.opt.spelllang = { "en_us" }
-- vim.opt.formatoptions:append("w") -- Break lines at whitespace
-- vim.opt.linebreak = true
-- vim.opt.wrap = true --vim.opt.formatoptions:append("l") -- Break long words
vim.diagnostic.config({
  -- Use the default configuration
  -- virtual_lines = true,
  virtual_text = false,

  -- Alternatively, customize specific options
  virtual_lines = {
    -- Only show virtual line diagnostics for the current cursor line
    current_line = true,
  },
})
