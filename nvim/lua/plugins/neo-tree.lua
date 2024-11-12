return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    popup_border_style = "rounded",
    window = {
      position = "float", -- Set position to float
      width = "fit-content", -- Customize the width of the floating window
      auto_expand_wdith = false,
      mappings = {
        ["<space>"] = "toggle_node",
        ["P"] = { "toggle_preview", config = { use_float = true } }, -- Enable preview in a floating window
      },
      popup = { -- settings that apply to float position only
        size = {
          height = "80%",
          width = "25%",
        },
        position = "50%",
      },
      -- popup = {
      --   position = { col = "0%", row = "0%" }, -- Left Corner the popup window
      -- },
    },
    default_component_configs = {
      git_status = {
        symbols = {
          -- Change type
          added = "✚", -- NOTE: you can set any of these to an empty string to not show them
          deleted = "✖",
          modified = "",
          renamed = "󰁕",
          -- Status type
          untracked = "",
          ignored = "",
          unstaged = "󱈸",
          staged = "",
          conflict = "",
        },
        align = "right",
      },
    },
    filesystem = {
      auto_follow_current_file = true,
      --follow_current_file = true,
      preview = true,
      use_libuv_file_watcher = true,
      window = {
        preview = true, -- Enables file preview
      },
    },
    preview = {
      enable = true, -- Enables preview by default
      always_show = true,
    },
  },
  config = function(_, opts)
    require("neo-tree").setup(opts)
    local events = require("neo-tree.events")
    local Preview = require("neo-tree.sources.common.preview")
    local manager = require("neo-tree.sources.manager")

    -- Subscribe to the event when Neo-tree window opens
    events.subscribe({
      event = events.AFTER_RENDER,
      handler = function()
        local state = manager.get_state_for_window()

        if state then
          vim.defer_fn(function()
            -- Call the toggle preview function with pcall for error handling
            state.config = { use_float = true }
            --require("neo-tree.command").execute({ source_name = state.name, action = "focus", reveal = true })
            local _success, err = pcall(Preview.toggle, state)

            if err then
              vim.notify("Error toggling preview: " .. err, vim.log.levels.ERROR)
            else
            end
          end, 50)
        end
        -- local state = manager.get_state("filesystem") -- Adjust the source
        -- local saved_state = vim.deepcopy(state)
      end,
    })
  end,
}
