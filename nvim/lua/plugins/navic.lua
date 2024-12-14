return {
  -- LSP symbol navigation for lualine
  {
    'SmiteshP/nvim-navic',
    lazy = true,
    init = function()
      vim.g.navic_silence = true

      -- Custom on_attach handler for nvim-navic
      local on_attach = function(client, buffer)
        if client.supports_method 'textDocument/documentSymbol' then
          require('nvim-navic').attach(client, buffer)
        end
      end

      -- Hook into `lspconfig` to append `on_attach`
      local lspconfig = require 'lspconfig'
      for _, server in pairs(lspconfig.util.available_servers()) do
        local config = lspconfig[server]
        local original_on_attach = config.on_attach
        config.on_attach = function(client, buffer)
          if original_on_attach then
            original_on_attach(client, buffer)
          end
          on_attach(client, buffer)
        end
      end
    end,
    opts = {
      separator = ' ',
      highlight = true,
      depth_limit = 5,
      icons = {
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
      lazy_update_context = true,
    },
  },

  -- Lualine integration
  {
    'nvim-lualine/lualine.nvim',
    optional = true,
    opts = function(_, opts)
      -- Ensure `sections` exists
      opts.sections = opts.sections or {}
      opts.sections.lualine_c = opts.sections.lualine_c or {}

      -- Add `nvim-navic` integration to lualine
      table.insert(opts.sections.lualine_c, {
        function()
          local navic = require 'nvim-navic'
          return navic.is_available() and navic.get_location() or ''
        end,
        color_correction = 'dynamic',
      })
    end,
  },
}
