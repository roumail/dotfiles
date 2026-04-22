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

local projects = {
  { label = "WezTerm Config", path = wezterm.config_dir },
}

-- Try to load private projects
-- ~/.config/wezterm/local_projects.lua
-- local_projects.lua
-- return {
--   { label = "Top Secret Work", path = "~/work/classified-project" },
--   { label = "Side Hustle",     path = "~/projects/money-maker" },
-- }
local has_local, local_projects = pcall(require, "local_projects")

if has_local then
  -- Merge the private list into the public list
  for _, p in ipairs(local_projects) do
    table.insert(projects, p)
  end
end

-- config.color_scheme = 'Batman'
config.font_size = 12
config.font = wezterm.font 'JetBrains Mono'
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }
-- config.disable_default_key_bindings = true

-- load plugin
local wez_tmux = require("plugins.wez-tmux.plugin")
wez_tmux.apply_to_config(config)
config.keys = remove_key(config.keys, "%", "LEADER|SHIFT")
config.keys = remove_key(config.keys, "\"", "LEADER|SHIFT")
config.keys = remove_key(config.keys, "l", "LEADER")

local my_keys = {
  -- splits
  --   key = "s", mods = "LEADER",action = wezterm.action.ShowLauncherArgs {flags = "FUZZY|WORKSPACES"}
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
  { key = "l", mods = "LEADER", action = wezterm.action.ActivatePaneDirection "Right" }

  -- Swapping Windows: https://github.com/sei40kr/wez-pain-control/blob/main/plugin/init.lua
  { key = "<", mods = "LEADER|SHIFT", action = act.MoveTabRelative(-1) },
  { key = ">", mods = "LEADER|SHIFT", action = act.MoveTabRelative(1) },
}

for _, key in ipairs(my_keys) do
  table.insert(config.keys, key)
end

return config
