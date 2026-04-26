local wezterm = require 'wezterm'
local config = wezterm.config_builder()

local function remove_key(keys, key, mods)
  local result = {}
  for _, k in ipairs(keys) do
    if not (k.key == key and k.mods == mods) then
      table.insert(result, k)
    end
  end
  return result
end


-- config.color_scheme = 'Batman'
config.font_size = 12
config.font = wezterm.font 'JetBrains Mono'
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }
config.window_close_confirmation = 'NeverPrompt'
config.automatically_reload_config = false
config.disable_default_key_bindings = true

-- load plugin
local wez_tmux = require("plugins.wez-tmux.plugin")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
local wez_sb_alert= wezterm.plugin.require("https://github.com/roumail/wez-status-bar-alert")
local wez_ws_alt = wezterm.plugin.require("https://github.com/roumail/wez-workspace-alt")
-- local wez_ws_alt = require("plugins.wez-workspace-alt.plugin")
-- local wez_projects= require("plugins.wez-projects-source.plugin")
-- local fifo_cache = require("plugins.fifo-cache.plugin")
local wez_projects = wezterm.plugin.require("https://github.com/roumail/wez-projects-source")
local projects = wez_projects.load_projects()
wez_tmux.apply_to_config(config)
wez_ws_alt.apply_to_config(config)

wezterm.on("window-config-reloaded", function(window, pane)
  wez_sb_alert.notify("Config reloaded")
end)
local status_sections = {
 tabline_x = {
    wez_sb_alert.component(),
 },
 tabline_y = {},
 tabline_z = { "datetime" },
}
tabline.setup({sections=status_sections})
tabline.apply_to_config(config)

config.keys = remove_key(config.keys, "%", "LEADER|SHIFT")
config.keys = remove_key(config.keys, "\"", "LEADER|SHIFT")
-- Am I tracking ctrl b s between open workspaces?
-- What about when I want to simply reopen in the same (not spawn a new window)
config.keys = remove_key(config.keys, "l", "LEADER")
config.keys = remove_key(config.keys, "s", "LEADER")


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
  {
    key = "w",
    mods = "LEADER",
    action = wez_ws_alt.project_selector({
      projects = projects,
      mode     = "workspace",
    }),
  },
  {
    key    = "t",
    mods   = "LEADER",
    action = wez_ws_alt.project_selector({
      projects = projects,
      mode     = "tab",
   }),
  },
  {
    key    = "V",
    mods   = "LEADER|SHIFT",
    action = wez_ws_alt.project_selector({
      projects = projects,
      mode     = "split_v",
   }),
  },
  {
    key    = "H",
    mods   = "LEADER|SHIFT",
    action = wez_ws_alt.project_selector({
      projects = projects,
      mode     = "split_h",
   }),
  },
  {
    key = "s",
    mods = "LEADER",
    action = wezterm.action.ShowLauncherArgs {flags = "FUZZY|WORKSPACES"}
  },
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
  { key = ">", mods = "LEADER|SHIFT", action = wezterm.action.MoveTabRelative(1) }
}

for _, key in ipairs(my_keys) do
  table.insert(config.keys, key)
end

return config
