return {
  {
    "gbprod/nord.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("nord").setup({
        diff = { mode = "fg" },
        on_colors = function(colors)
          colors.polar_night = {
            origin = "#212632",
            bright = "#2E3440",
            brighter = "#3B4252",
            brightest = "#434C5E",
            light = "#4C566A",
            lighter = "#5A6984",
            lightest = "#7e8ca7",
          }
        end,

        on_highlights = function(highlights, colors)
          local green = vim.tbl_extend("force", { fg = "#c1d3b2", bg = "#415430" }, {})
          local red = vim.tbl_extend("force", { fg = "#d4959b", bg = "#662a2f" }, {})
          local purple = vim.tbl_extend("force", { fg = colors.aurora.purple }, {})
          -- local unterline_purple = vim.tbl_extend("force", { fg = colors.aurora.purple }, { underline = true })
          local yellow = vim.tbl_extend("force", { fg = colors.aurora.yellow }, {})
          local orange = vim.tbl_extend("force", { fg = colors.aurora.orange }, {})

          local storm = vim.tbl_extend("force", { fg = colors.snow_storm.origin }, { bold = true })
          local polar_night = vim.tbl_extend(
            "force",
            { fg = colors.polar_night.lighter },
            { bold = true, italic = true }
          )

          local artic_water = vim.tbl_extend("force", { fg = colors.frost.artic_water }, {})
          local italic_artic_water = vim.tbl_extend(
            "force",
            { fg = colors.frost.artic_water },
            { bold = true, italic = true }
          )
          local italic_artic_ocean = vim.tbl_extend("force", { fg = colors.frost.artic_ocean }, { italic = true })
          local artic_ocean = vim.tbl_extend("force", { fg = colors.frost.artic_ocean }, {})

          highlights["@punctuation.delimiter"] = purple
          highlights["@tag.attribute"] = purple
          highlights["@tag"] = artic_water
          highlights["@tag.tsx"] = italic_artic_water
          highlights["@tag.builtin.tsx"] = storm

          highlights["@comment"] = polar_night

          highlights["@type.builtin"] = artic_water

          highlights["@variable.parameter"] = artic_water
          --highlights["@type"] = artic_ocean

          highlights["@keyword.coroutine"] = yellow
          highlights["@keyword.import"] = italic_artic_ocean
          highlights["@boolean"] = artic_ocean

          highlights["@number"] = orange
          -- FZF-Lua highlight group overrides
          -- highlights.FzfLuaNormal = { link = "TelescopeNormal" }
          -- highlights.FzfLuaNormal = yellow

          highlights.FzfLuaBorder = polar_night -- { link = "TelescopeBorder" }
          highlights.FzfLuaTitle = artic_water -- { link = "TelescopeTitle" }

          highlights.GitSignsDeleteInline = red
          highlights.GitSignsAddInline = green

          highlights.BlinkCmpDocBorder = polar_night
          -- highlights.FzfLuaPreviewNormal = { link = "TelescopePreviewNormal" }
          -- highlights.FzfLuaPreviewBorder = artic_water -- { link = "TelescopePreviewBorder" }
          -- highlights.FzfLuaPreviewTitle = { link = "TelescopePreviewTitle" }
          -- highlights.FzfLuaCursor = { link = "TelescopeSelection" }
          -- highlights.FzfLuaCursorLine = { link = "TelescopeSelectionCaret" }
          -- highlights.FzfLuaSearch = { link = "TelescopeMatching" }
          -- highlights.FzfLuaResultsNormal = { link = "TelescopeResultsNormal" }
          -- highlights.FzfLuaResultsBorder = { link = "TelescopeResultsBorder" }
          -- highlights.FzfLuaResultsTitle = { link = "TelescopeResultsTitle" }
          -- highlights.FzfLuaPromptNormal = { link = "TelescopePromptNormal" }
          -- highlights.FzfLuaPromptBorder = { link = "TelescopePromptBorder" }
          -- highlights.FzfLuaPromptPrefix = { link = "TelescopePromptPrefix" }
        end,
      })

      vim.cmd.colorscheme("nord")
    end,
    install = {
      colorscheme = { "nord" },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nord",
    },
  },

  -- "tokyonight.nvim",
  -- opts = {
  --   -- transparent = true,
  --   style = "night",
  --   styles = {
  --     -- sidebars = "transparent",
  --     -- floats = "transparent",
  --   },
  --   on_highlights = function(hl, c)
  --     -- Vertical split line
  --     -- hl.VertSplit = { fg = "#00FFFF", bg = "NONE" }
  --     -- Horizontal split line (WinSeparator covers both)
  --     hl.WinSeparator = { fg = "#565f89", bg = "NONE" }
  --   end,
  -- },
}
