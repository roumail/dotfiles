local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- config.color_scheme = 'Batman'
config.font_size = 12
config.font = wezterm.font 'JetBrains Mono'
-- leader a perhaps so it doesn't clash with tmux
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }
config.window_close_confirmation = 'NeverPrompt'
config.automatically_reload_config = false
config.disable_default_key_bindings = true
-- https://wezterm.org/config/lua/config/visual_bell.html
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
  target = 'CursorColor',
}
-- load plugin
local wez_tmux = require("plugins.wez-tmux.plugin")
local helpers = require("helpers")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
local wez_sb_alert= wezterm.plugin.require("https://github.com/roumail/wez-status-bar-alert")
local wez_ws_alt = wezterm.plugin.require("https://github.com/roumail/wez-project-spaces")
-- local wez_ws_alt = wezterm.plugin.require("file:///Users/rohailtaimour/.config/wezterm/plugins/wez-project-spaces")
-- local wez_ws_alt = require("plugins.wez-project-spaces.plugin")
wez_tmux.apply_to_config(config)
wez_ws_alt.apply_to_config(config)

wezterm.on("window-config-reloaded", function(window, pane)
  wez_sb_alert.notify("Config reloaded")
end)

local status_sections = {
  tab_active = {
    'index',
    helpers.processed_name ,
    { 'zoomed', padding = 0 },
  },
  tab_inactive = { 'index',  helpers.processed_name },
  tabline_x = {
    wez_sb_alert.component(),
  },
  tabline_y = {},
  tabline_z = { "datetime" },
}
tabline.setup({sections=status_sections})
tabline.apply_to_config(config)

config.keys = helpers.remove_key(config.keys, "%", "LEADER|SHIFT")
config.keys = helpers.remove_key(config.keys, "\"", "LEADER|SHIFT")
config.keys = helpers.remove_key(config.keys, "l", "LEADER")
config.keys = helpers.remove_key(config.keys, "s", "LEADER")
config.keys = helpers.remove_key(config.keys, "x", "LEADER")
config.keys = helpers.remove_key(config.keys, "&", "LEADER|SHIFT")
-- Select output of entire command when triple-clicking
config.mouse_bindings = {
  {
    event = { Down = { streak = 3, button = 'Left' } },
    action = wezterm.action.SelectTextAtMouseCursor 'SemanticZone',
    mods = 'NONE',
  },
}

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  config.wsl_domains = {
    {
      -- The name of this specific domain.  Must be unique amonst all types
      -- of domain in the configuration file.
      name = 'WSL:Debian',

      -- The name of the distribution.  This identifies the WSL distribution.
      -- It must match a valid distribution from your `wsl -l -v` output in
      -- order for the domain to be useful.
      distribution = 'Debian',

      -- The username to use when spawning commands in the distribution.
      -- If omitted, the default user for that distribution will be used.

      -- username = "hunter",

      -- The current working directory to use when spawning commands, if
      -- the SpawnCommand doesn't otherwise specify the directory.

      default_cwd = "~",

      -- This approach doesn't work and always lands in cmd windows home

      -- default_prog = {'C:\\Windows\\System32\\wsl.exe', '--distribution', 'Debian'}
    },
  }
  config.default_domain = "WSL:Debian"
end

local my_keys = {
  {
    key = "p",
    mods = "ALT",
    action = wezterm.action.ActivateCommandPalette,
  },
  {
    key = "Enter",
    mods = "ALT",
    action = wezterm.action.ToggleFullScreen,
  },
  {
    key = "c",
    mods = "CMD",
    action = wezterm.action.CopyTo "Clipboard",
  },
  {
    key = "v",
    mods = "CMD",
    action = wezterm.action.PasteFrom "Clipboard",
  },
  {
    key = "c",
    mods = "SHIFT|CTRL",
    action = wezterm.action.CopyTo "Clipboard",
  },
  {
    key = "v",
    mods = "SHIFT|CTRL",
    action = wezterm.action.PasteFrom "Clipboard",
  },
  {
    key = "q",
    mods = "LEADER",
    action = wezterm.action.QuitApplication,
  },
  {
    key = "r",
    mods = "LEADER",
    action = wezterm.action.ReloadConfiguration,
  },
  {
    key = "d",
    mods = "LEADER",
    action = wezterm.action.ShowDebugOverlay,
  },
  {
    key = "N",
    mods = "LEADER|SHIFT",
    action = wezterm.action.SpawnCommandInNewWindow { domain = "CurrentPaneDomain" },
  },
  -- Scroll up/down to previous/next prompt
  {
    key = 'UpArrow', mods = 'LEADER',
    action = wezterm.action.ScrollToPrompt(-1)
  },
  {
    key = 'DownArrow', mods = 'LEADER',
    action = wezterm.action.ScrollToPrompt(1)
  },
  {key = "x", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = false })},
  { key = "&", mods = "LEADER|SHIFT", action = wezterm.action.CloseCurrentTab({ confirm = false }) },
   -- splits
  {
    key = "|",
    mods = "LEADER|SHIFT",
    action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" },
  },
  {
    key = "-",
    mods = "LEADER",
    action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" },
  },
  { key = "b", mods = "LEADER", action = wezterm.action.ActivateLastTab },

  -- navigation
  { key = "h", mods = "LEADER", action = wezterm.action.ActivatePaneDirection "Left" },
  { key = "j", mods = "LEADER", action = wezterm.action.ActivatePaneDirection "Down" },
  { key = "k", mods = "LEADER", action = wezterm.action.ActivatePaneDirection "Up" },
  { key = "l", mods = "LEADER", action = wezterm.action.ActivatePaneDirection "Right" },

  -- Swapping Windows: https://github.com/sei40kr/wez-pain-control/blob/main/plugin/init.lua
  { key = "<", mods = "LEADER|SHIFT", action = wezterm.action.MoveTabRelative(-1) },
  { key = ">", mods = "LEADER|SHIFT", action = wezterm.action.MoveTabRelative(1) },
  {
    key = 'Z',
    mods = 'LEADER|SHIFT',
    -- Activate the `resize_panes` keytable
    action = wezterm.action.ActivateKeyTable {
      name = 'resize_panes',
      -- Ensures the keytable stays active after it handles its
      -- first keypress.
      one_shot = false,
      -- Deactivate the keytable after a timeout.
      timeout_milliseconds = 1000,
    }
  },
}
config.key_tables = config.key_tables or {}
config.key_tables.resize_panes = {
    helpers.resize_pane('j', 'Down'),
    helpers.resize_pane('k', 'Up'),
    helpers.resize_pane('h', 'Left'),
    helpers.resize_pane('l', 'Right'),
}

-- local function make_typed_zone(pair, direction, zone_key, zone_type)
--   local action = {}

--   if direction == "forward" then
--     action = { MoveForwardZoneOfType = zone_type }
--   else
--     action = { MoveBackwardZoneOfType = zone_type }
--   end

--   return {
--     key = zone_key,
--     mods = pair,
--     action = wezterm.action.CopyMode(action),
--   }
-- end
-- -- config.key_tables.copy_mode = config.key_tables.copy_mode or {}
-- local mappings = {

--   -- Typed zones: [ ] layer
--   make_typed_zone("[", "backward", "p", "Prompt"),
--   make_typed_zone("]", "forward",  "p", "Prompt"),

--   make_typed_zone("[", "backward", "i", "Input"),
--   make_typed_zone("]", "forward",  "i", "Input"),

--   make_typed_zone("[", "backward", "o", "Output"),
--   make_typed_zone("]", "forward",  "o", "Output"),

-- }
-- -- table.insert(config.key_tables.copy_mode, {
-- --   key = 'x',
-- --   mods = 'NONE',
-- --   action = wezterm.action.CopyMode { MoveForwardZoneOfType = 'Prompt' },
-- --   action = wezterm.action.CopyMode { MoveForwardZoneOfType = 'Output' },
-- --   action = wezterm.action.CopyMode { MoveForwardZoneOfType = 'Input' },
-- --   action = wezterm.action.CopyMode { MoveBackwardZoneOfType = 'Prompt' },
-- --   action = wezterm.action.CopyMode { MoveBackwardZoneOfType = 'Output' },
-- --   action = wezterm.action.CopyMode { MoveBackwardZoneOfType = 'Input' },
-- --
-- --           Semantic zones: { } layer
-- --           simple("(", "s", "MoveBackwardSemanticZone"),
-- --           simple(")", "s", "MoveForwardSemanticZone"),
-- --           {
-- --               key = key,
-- --               mods = pair,
-- --               action = wezterm.action.CopyMode(action_name),
-- --             }
-- --   action = wezterm.action.CopyMode 'MoveBackwardSemanticZone'
-- --   action = wezterm.action.CopyMode 'MoveForwardSemanticZone'
-- --
-- --   action = wezterm.action.CopyMode { SetSelectionMode = 'Cell' },
-- --   -- action = wezterm.action.CopyMode { SetSelectionMode = 'SemanticZone' },
-- -- })

for _, key in ipairs(my_keys) do
  table.insert(config.keys, key)
end

return config
