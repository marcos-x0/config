return {
  "saghen/blink.cmp",
  dependencies = {
    "rafamadriz/friendly-snippets",
    -- add blink.compat to dependencies
    {
      "saghen/blink.compat",
      optional = true, -- make optional so it's only enabled if any extras need it
      opts = {},
      version = not vim.g.lazyvim_blink_main and "*",
    },
  },
  opts = {
    appearance = {
      nerd_font_variant = "mono",
      kind_icons = {
        --[[
        -- vscode icons

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

        --]]
        Text = "󰉿",
        Method = "󰊕",
        Function = "󰊕",
        Constructor = "󰒓",

        Field = "󰜢",
        Variable = "󰆦",
        Property = "󰖷",

        Class = "󱡠",
        Interface = "󱡠",
        Struct = "󱡠",
        Module = "󰅩",

        Unit = "󰪚",
        Value = "󰦨",
        Enum = "󰦨",
        EnumMember = "󰦨",

        Keyword = "󰻾",
        Constant = "󰏿",

        Snippet = "󱄽",
        Color = "󰏘",
        File = "󰈔",
        Reference = "󰬲",
        Folder = "󰉋",
        Event = "󱐋",
        Operator = "󰪚",
        TypeParameter = "󰬛",
      },
    },
    keymap = {
      preset = "default",
      ["<CR>"] = { "fallback" },
      ["<Tab>"] = { "select_next", "fallback" },
      -- ["<S-Tab>"] = { "select_prev", "fallback" },
      ["<ESC>"] = { "hide", "fallback" },
      ["<C-CR>"] = { "accept", "fallback" },
      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      -- stylua: ignore start
      ['<C-1>'] = { function(cmp) cmp.accept({ index = 1 }) end },
      ['<C-2>'] = { function(cmp) cmp.accept({ index = 2 }) end },
      ['<C-3>'] = { function(cmp) cmp.accept({ index = 3 }) end },
      ['<C-4>'] = { function(cmp) cmp.accept({ index = 4 }) end },
      ['<C-5>'] = { function(cmp) cmp.accept({ index = 5 }) end },
      ['<C-6>'] = { function(cmp) cmp.accept({ index = 6 }) end },
      ['<C-7>'] = { function(cmp) cmp.accept({ index = 7 }) end },
      ['<C-8>'] = { function(cmp) cmp.accept({ index = 8 }) end },
      ['<C-9>'] = { function(cmp) cmp.accept({ index = 9 }) end },
      ['<C-0>'] = { function(cmp) cmp.accept({ index = 10 }) end },
      -- stylua: ignore end
    },

    completion = {
      menu = {
        scrollbar = false,
        border = "rounded",
        winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
        draw = {
          columns = { { "item_idx" }, { "kind_icon" }, { "label", "label_description", gap = 1 } },
          components = {
            item_idx = {
              text = function(ctx)
                return ctx.idx == 10 and "0" or ctx.idx >= 10 and " " or tostring(ctx.idx)
              end,
              highlight = "BlinkCmpItemIdx", -- optional, only if you want to change its color
            },
          },
        },
      },
      list = {
        selection = nil,
      },

      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        window = {
          border = "rounded",
        },
      },
      ghost_text = {
        enabled = false,
      },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    signature = { enabled = true, window = { border = "single" } },
  },
}
