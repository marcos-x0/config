return {
  'gbprod/nord.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('nord').setup {
      diff = { mode = 'fg' },
      on_colors = function(colors)
        colors.polar_night = {
          origin = '#212632',
          bright = '#2E3440',
          brighter = '#3B4252',
          brightest = '#434C5E',
          light = '#4C566A',
          lighter = '#7e8ca7',
        }
      end,

      on_highlights = function(highlights, colors)
        local purple = vim.tbl_extend('force', { fg = colors.aurora.purple }, {})
        -- local unterline_purple = vim.tbl_extend("force", { fg = colors.aurora.purple }, { underline = true })
        local yellow = vim.tbl_extend('force', { fg = colors.aurora.yellow }, {})
        local orange = vim.tbl_extend('force', { fg = colors.aurora.orange }, {})

        local storm = vim.tbl_extend('force', { fg = colors.snow_storm.origin }, { bold = true })
        local polar_night = vim.tbl_extend('force', { fg = colors.polar_night.light }, { bold = true, italic = true })

        local artic_water = vim.tbl_extend('force', { fg = colors.frost.artic_water }, {})
        local italic_artic_water = vim.tbl_extend('force', { fg = colors.frost.artic_water }, { bold = true, italic = true })
        local italic_artic_ocean = vim.tbl_extend('force', { fg = colors.frost.artic_ocean }, { italic = true })
        local artic_ocean = vim.tbl_extend('force', { fg = colors.frost.artic_ocean }, {})

        highlights['@punctuation.delimiter'] = purple
        highlights['@tag.attribute'] = purple
        highlights['@tag'] = artic_water
        highlights['@tag.tsx'] = italic_artic_water
        highlights['@tag.builtin.tsx'] = storm

        highlights['@comment'] = polar_night

        highlights['@type.builtin'] = artic_water

        highlights['@variable.parameter'] = artic_water
        --highlights["@type"] = artic_ocean

        highlights['@keyword.coroutine'] = yellow
        highlights['@keyword.import'] = italic_artic_ocean
        highlights['@boolean'] = artic_ocean

        highlights['@number'] = orange

        -- Add a custom highlight for the indent scope
        highlights['IndentScopeHighlight'] = { fg = colors.polar_night.lighter, bold = true }

        -- Add BlinkCmpKind highlights for all kinds
        for _, kind in ipairs(require('blink.cmp.types').CompletionItemKind) do
          highlights['BlinkCmpKind' .. kind] = {
            fg = colors.polar_night.light,
            bg = colors.snow_storm.origin, -- Black foreground
          }
        end

        highlights['BlinkCmpMenuSelection'] = {
          bg = colors.polar_night.light,
          fg = colors.snow_storm.origin, -- Black foreground
        }
      end,
    }

    vim.cmd.colorscheme 'nord'
  end,
  install = {
    colorscheme = { 'nord' },
  },
}
