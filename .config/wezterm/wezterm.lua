local wezterm = require 'wezterm'

local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

config.color_scheme = 'Tomorrow Night'

config.hide_tab_bar_if_only_one_tab = true
config.inactive_pane_hsb = {
  saturation = 0.5,
  brightness = 0.5,
}
-- config.window_background_opacity = 0.8
-- config.window_background_image = '/home/juergen/Pictures/terminalBackground.jpg'
config.background = {
  -- This is the deepest/back-most layer. It will be rendered first
  {
    source = {
      File = '/Users/juergen.czerny/.config/wezterm/terminalBackground.png',
    },
    -- The texture tiles vertically but not horizontally.
    -- When we repeat it, mirror it so that it appears "more seamless".
    -- An alternative to this is to set `width = "100%"` and have
    -- it stretch across the display
    repeat_x = 'Mirror',
    hsb = dimmer,
    -- When the viewport scrolls, move this layer 10% of the number of
    -- pixels moved by the main viewport. This makes it appear to be
    -- further behind the text.
    attachment = { Parallax = 0.1 },
    opacity = 0.8
  }
}

return config