local wezterm = require("wezterm")

local config = {
	font = wezterm.font("JetBrains Mono"),
	font_size = 16.0,
	harfbuzz_features = { "calt=1", "clig=1", "liga=1" },
	hide_tab_bar_if_only_one_tab = true,
	use_fancy_tab_bar = false,
}

config.color_scheme = "Catppuccin Mocha"

return config
