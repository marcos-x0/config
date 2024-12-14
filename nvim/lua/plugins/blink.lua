return {
  {
    'hrsh7th/nvim-cmp',
    optional = true,
    enabled = false,
  },
  {
    'saghen/blink.cmp',
    version = '*', -- Replace with the desired version, "*" for the latest stable
    build = 'cargo build --release', -- Adjust if using a pre-built version
    opts_extend = {
      'sources.completion.enabled_providers',
      'sources.compat',
      'sources.default',
    },
    dependencies = {
      'rafamadriz/friendly-snippets',
      'onsails/lspkind.nvim', -- Add lspkind for icons
      {
        'saghen/blink.compat',
        optional = true, -- Optional dependency
        opts = {},
        version = '*', -- Latest stable version
      },
    },
    event = 'InsertEnter',
    opts = {
      appearance = {
        use_nvim_cmp_as_default = false, -- Fallback highlights
        nerd_font_variant = 'mono', -- Adjust spacing for Nerd Font Mono
      },
      completion = {
        accept = {
          auto_brackets = {
            enabled = true, -- Enable auto-brackets
          },
        },
        menu = {
          draw = {
            treesitter = { 'lsp' }, -- Use treesitter for better menus
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        ghost_text = {
          enabled = vim.g.ai_cmp, -- Enable based on global variable
        },
      },
      sources = {
        compat = {},
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        cmdline = {},
      },
      keymap = {
        preset = 'enter', -- Default preset
        ['<C-y>'] = { 'select_and_accept' },
        ['<Tab>'] = {
          function()
            -- Define a fallback function for <Tab>
            if vim.fn.pumvisible() == 1 then
              return vim.api.nvim_replace_termcodes('<C-n>', true, true, true)
            else
              return vim.api.nvim_replace_termcodes('<Tab>', true, true, true)
            end
          end,
        },
      },
    },
    config = function(_, opts)
      -- Setup compatibility sources
      local enabled = opts.sources.default
      for _, source in ipairs(opts.sources.compat or {}) do
        opts.sources.providers[source] = vim.tbl_deep_extend('force', { name = source, module = 'blink.compat.source' }, opts.sources.providers[source] or {})
        if type(enabled) == 'table' and not vim.tbl_contains(enabled, source) then
          table.insert(enabled, source)
        end
      end

      -- Enable completion providers
      if not opts.sources.completion then
        opts.sources.completion = {}
      end
      opts.sources.completion.enabled_providers = enabled

      -- Unset custom properties for validation
      opts.sources.compat = nil

      -- Handle symbol kinds
      for _, provider in pairs(opts.sources.providers or {}) do
        if provider.kind then
          local CompletionItemKind = require('blink.cmp.types').CompletionItemKind
          local kind_idx = #CompletionItemKind + 1
          CompletionItemKind[kind_idx] = provider.kind
          CompletionItemKind[provider.kind] = kind_idx

          local transform_items = provider.transform_items
          provider.transform_items = function(ctx, items)
            items = transform_items and transform_items(ctx, items) or items
            for _, item in ipairs(items) do
              item.kind = kind_idx or item.kind
            end
            return items
          end

          provider.kind = nil
        end
      end

      -- Final Blink configuration
      require('blink.cmp').setup(opts)
    end,
  },
  -- Icons support
  {
    'saghen/blink.cmp',
    opts = function(_, opts)
      opts.appearance = opts.appearance or {}
      opts.appearance.kind_icons = vim.tbl_extend('keep', {
        Color = '██', -- Use block for color items
      }, require('lspkind').presets.default) -- Use lspkind for icons
    end,
  },
  -- Catppuccin theme integration
  {
    'catppuccin',
    optional = true,
    opts = {
      integrations = { blink_cmp = true },
    },
  },
}
