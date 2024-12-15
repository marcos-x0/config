---@diagnostic disable: missing-fields
return {
  'folke/noice.nvim',
  dependencies = {
    'MunifTanjim/nui.nvim', -- Required for UI
    'rcarriga/nvim-notify', -- Optional: For notifications
  },
  config = function()
    local noice = require 'noice'

    noice.setup {
      messages = {
        view = 'notify', -- Route messages to `nvim-notify` for enhanced display
      },
      lsp = {
        progress = {
          enabled = true, -- Show LSP progress in notifications
        },
        hover = {
          enabled = false, -- Disable hover to use Neovim's default behavior
        },
        signature = {
          enabled = false, -- Disable signature help to use LSP
        },
      },
      popupmenu = {
        enabled = true, -- Use a custom popupmenu
      },
      notify = {
        enabled = true, -- Integrate with `nvim-notify`
      },
      presets = {
        bottom_search = true, -- Classic bottom command-line for search
        command_palette = true, -- Use a command palette for command-line
        long_message_to_split = true, -- Route long messages to a split
        inc_rename = true,
      },
    }

    vim.keymap.set('n', '<leader>nd', function()
      noice.cmd 'dismiss'
    end, { desc = 'Dismiss all Noice notifications' })

    -- Set `nvim-notify` as the default notification provider
    vim.notify = require 'notify'
  end,
}
