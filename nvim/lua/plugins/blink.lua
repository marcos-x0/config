return {
  {
    'saghen/blink.cmp',
    version = '*',
    build = 'cargo build --release',
    dependencies = {
      'L3MON4D3/LuaSnip', -- Snippet engine
      'rafamadriz/friendly-snippets', -- Predefined snippets
      { 'saghen/blink.compat', version = '*' }, -- Compatibility layer
    },
    event = 'InsertEnter',
    opts = {
      appearance = {
        nerd_font_variant = 'mono',
        kind_icons = {
          Text = '',
          Method = '',
          Function = '',
          Constructor = '',
          Field = '',
          Variable = '',
          Class = '',
          Interface = '',
          Module = '',
          Property = '',
          Unit = '',
          Value = '',
          Enum = '',
          Keyword = '',
          Snippet = '',
          Color = '',
          File = '',
          Reference = '',
          Folder = '',
          EnumMember = '',
          Constant = '',
          Struct = '',
          Event = '',
          Operator = '',
          TypeParameter = '',
        },
      },
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        ghost_text = {
          enabled = false,
        },
      },
      sources = {
        compat = { 'luasnip' },
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
    },
    config = function(_, opts)
      require('luasnip.loaders.from_vscode').lazy_load()

      local cmp = require 'blink.cmp'

      -- Ensure no item is automatically selected
      opts.completion = opts.completion or {}
      opts.completion.selection = nil -- This prevents default selection of the first item

      opts.completion.behavior = 'replace' -- Ensure full word replacement on confirm

      opts.keymap = {

        -- Tab to move to the next item
        ['<Tab>'] = { 'select_next', 'fallback' },

        -- Shift-Tab to move to the previous item
        ['<S-Tab>'] = { 'select_prev', 'fallback' },

        -- Enter to confirm the selection
        ['<C-CR>'] = {
          'accept',
          function()
            cmp.hide() -- Explicitly hide the dropdown
          end,
          'fallback',
        },

        -- Enter to confirm the selection
      }

      -- Setup Blink with the updated opts
      cmp.setup(opts)
    end,
  },
}
