-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
-- vim.cmd([[
--   augroup DiagnosticModeControl
--     autocmd!
--     " Show or hide diagnostics based on the toggle when leaving insert mode or changing text
--     autocmd InsertEnter,InsertLeave,TextChanged,TextChangedI,ModeChanged  * lua if not _G.diagnostics_enabled then vim.diagnostic.hide(nil, 0) end
--   augroup END
-- ]])

-- Autocommands to control diagnostics updates
-- vim.cmd([[
--       augroup DiagnosticModeControl
--         autocmd!
--         " Disable diagnostics when entering insert mode
--         autocmd InsertEnter * lua vim.diagnostic.hide(nil, 0)
--         " Re-enable diagnostics when leaving insert mode
--         autocmd InsertLeave * lua vim.diagnostic.show(nil, 0)
--       augroup END
--     ]])
-- vim.api.nvim_create_autocmd("InsertEnter", {
--   callback = function()
--     require("null-ls").disable()
--     vim.notify("none-ls disabled in Insert mode", vim.log.levels.INFO)
--   end,
--   desc = "Disable none-ls in Insert mode",
-- })

-- Autocmd to disable none-ls in Insert mode
vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    local null_ls = require("null-ls")
    if _G.none_ls_enabled then
      null_ls.disable({})
      -- vim.notify("none-ls disabled in Insert mode", vim.log.levels.INFO)
    end
  end,
  desc = "Disable none-ls in Insert mode",
})

-- Autocmd to restore none-ls state based on the toggle when leaving Insert mode
vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    local null_ls = require("null-ls")
    if _G.none_ls_enabled then
      null_ls.enable({})
      -- vim.notify("none-ls enabled after Insert mode", vim.log.levels.INFO)
    end
  end,
  desc = "Restore none-ls state after Insert mode",
})
