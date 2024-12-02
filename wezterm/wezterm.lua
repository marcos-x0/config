local wezterm = require("wezterm")

local act = wezterm.action

local config = wezterm.config_builder()

config.color_scheme = "tokyonight_night"
config.colors = {
	split = "#555555",

	visual_bell = "#000000",
	tab_bar = {
		active_tab = {
			bg_color = "#1a1a1a",
			fg_color = "#c0c0c0",
			intensity = "Bold",
			underline = "Single",
			italic = false,
			strikethrough = false,
		},
	},
}

config.audible_bell = "Disabled"
config.visual_bell = {
	fade_in_function = "EaseIn",
	fade_in_duration_ms = 64,
	fade_out_function = "EaseOut",
	fade_out_duration_ms = 32,
}

config.font = wezterm.font({ family = "IosevkaMgjTerm Nerd Font" })
config.font_size = 11.5
config.line_height = 1.0
config.native_macos_fullscreen_mode = false

config.inactive_pane_hsb = {
	saturation = 0.7,
	brightness = 0.4,
}

config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"
config.window_padding = {
	left = 10,
	right = 10,
	top = 10,
	bottom = 10,
}

config.window_background_opacity = 0.75

-- Setup nvim integration
--
--
--
local function is_nvim(pane)
	local process_name = pane:get_foreground_process_name()

	-- Extract the base name from the full path
	local base_name = string.match(process_name, "([^/]+)$") -- This extracts everything after the last "/"
	wezterm.log_info("Foreground process: ", process_name, " | Base name: ", base_name)

	-- Return true if the base name is 'nvim'
	return base_name == "nvim"
end
-- Detect Neovim based on the running process

-- Helper function to move between panes or pass movement to Neovim
local function move_pane_or_send_to_nvim(window, pane, direction, action)
	if is_nvim(pane) then
		-- If Neovim is running, send the navigation key to Neovim
		window:perform_action(wezterm.action.SendKey({ key = direction, mods = "META|CTRL" }), pane)
	else
		-- Otherwise, move the WezTerm pane
		window:perform_action(action, pane)
	end
end

local function action_callback(direction, action)
	return wezterm.action_callback(function(window, pane)
		move_pane_or_send_to_nvim(window, pane, direction, action)
	end)
end

-- Log for splits
local function split_pane_or_send_to_nvim(window, pane, split_type)
	wezterm.log_info("Attempting to split pane. Split type: ", split_type)
	if is_nvim(pane) then
		local key = split_type == "horizontal" and "-" or "\\"
		wezterm.log_info("Neovim detected in pane, sending split key: ", key)
		window:perform_action(wezterm.action.SendKey({ key = key, mods = "CTRL|META" }), pane)
	else
		local action = split_type == "horizontal" and wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" })
			or wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" })
		wezterm.log_info("Neovim not detected, performing WezTerm split: ", split_type)
		window:perform_action(action, pane)
	end
end

config.keys = {
	{ key = "R", mods = "CTRL|META", action = act.ReloadConfiguration },
	{ key = "RightArrow", mods = "META|SUPER", action = act.ActivateTabRelative(1) },
	{ key = "LeftArrow", mods = "META|SUPER", action = act.ActivateTabRelative(-1) },
	{ key = "Enter", mods = "CTRL|META", action = act.TogglePaneZoomState },
	{
		key = "\\",
		mods = "CTRL|SUPER",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		-- split_pane_or_send_to_nvim(window, pane, "horizontal")
	},
	{
		key = "-",
		mods = "CTRL|SUPER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
		-- split_pane_or_send_to_nvim(window, pane, "vertical")
	},
	{
		key = "?",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "_",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "\\",
		mods = "CTRL|META",
		action = wezterm.action_callback(function(window, pane)
			split_pane_or_send_to_nvim(window, pane, "horizontal")
		end),
	},
	{
		key = "-",
		mods = "CTRL|META",
		action = wezterm.action_callback(function(window, pane)
			split_pane_or_send_to_nvim(window, pane, "vertical")
		end),
	},

	-- {
	-- 	key = "-",
	-- 	mods = "CTRL|META",
	-- 	action = action_callback("-", act.SplitVertical({ domain = "CurrentPaneDomain" })),
	-- },
	-- {
	-- 	key = "\\",
	-- 	mods = "CTRL|META",
	-- 	action = action_callback("-", act.SplitHorizontal({ domain = "CurrentPaneDomain" })),
	-- },
	{ key = "LeftArrow", mods = "CTRL|META", action = action_callback("LeftArrow", act.ActivatePaneDirection("Left")) },
	{ key = "DownArrow", mods = "CTRL|META", action = action_callback("DownArrow", act.ActivatePaneDirection("Down")) },
	{ key = "UpArrow", mods = "CTRL|META", action = action_callback("UpArrow", act.ActivatePaneDirection("Up")) },
	{
		key = "RightArrow",
		mods = "CTRL|META",
		action = action_callback("RightArrow", act.ActivatePaneDirection("Right")),
	},
	{ key = "h", mods = "CTRL|META", action = action_callback("h", act.ActivatePaneDirection("Left")) },
	{ key = "j", mods = "CTRL|META", action = action_callback("j", act.ActivatePaneDirection("Down")) },
	{ key = "k", mods = "CTRL|META", action = action_callback("h", act.ActivatePaneDirection("Up")) },
	{ key = "l", mods = "CTRL|META", action = action_callback("j", act.ActivatePaneDirection("Right")) },
}

return config
