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

local temp_status = ""


local function format_notification()
  if temp_status == "" then
      return ""
  end

  return wezterm.format({
      { Attribute = { Intensity = 'Bold' } },
      { Foreground = { AnsiColor = 'Fuchsia' } },
      { Background = { Color = '#2b2042' } }, -- A subtle dark purple
      { Text = '  󱐋 ' .. temp_status .. '  ' },
      'ResetAttributes',
  })
end

-- There's an issue with notifications (windows)
-- Can't use tabline and set right status together
wezterm.on("window-config-reloaded", function(window, pane)
  temp_status ="Config reloaded"
  wezterm.time.call_after(2, function()
    temp_status = ""
  end)
end)

local workspace_cache

local function track_workspace(name)
  if name and name ~= "" then
    workspace_cache.add_value(name)
  end
end

local function perform_tracked_switch(window, pane, name, spawn)
  if not name or name == "" then
    return
  end

  local current = window:active_workspace()
  track_workspace(current)
  track_workspace(name)

  local action = { name = name }
  if spawn then
    action.spawn = spawn
  end

  window:perform_action(wezterm.action.SwitchToWorkspace(action), pane)
end

local function switch_workspace(callback)
  return wezterm.action_callback(function(window, pane, path, label)
    local function do_switch(name, spawn)
      perform_tracked_switch(window, pane, name, spawn)
    end
    callback(do_switch, path, label)
  end)
end


local function switch_to_previous_workspace_action()
  return wezterm.action_callback(function(window, pane)
    track_workspace(window:active_workspace())
    if not workspace_cache.is_ready() then
      return
    end

    local history = workspace_cache.get_cache()
    local current = window:active_workspace()
    local first = history[1]
    local second = history[2]

    local target = first
    if first == current then
      target = second
    end

    if target and target ~= current then
      perform_tracked_switch(window, pane, target)
    end
  end)
end
-- 17:02:46.238  INFO   logging > lua: the focus state of  0 from  default  active tab is  MuxTab(tab_id:0, pid:25128)  last active workspace was  default
-- wezterm.on('update-status', function(window, pane)
--   sync_workspace_state(window)
--   wezterm.log_info('current=', current_workspace, ' last=', last_workspace)
-- end)
-- on linux home and config dir can be the same
-- on windows home dir and config dir would be different
-- Specifically the config file is in the dotfiles directory and
-- local projects.lua can be in the same directory
local projects = {
  { label = "Dotfiles", path = wezterm.config_dir .. "/../../../" },
}

-- -- local_projects.lua
-- -- return {
-- --   { label = "Top Secret Work", path = "~/work/classified-project" },
-- --   { label = "Side Hustle",     path = "~/projects/money-maker" },
-- -- }
local local_projects_path = wezterm.config_dir .. "/../local/local_projects.lua"
local ok, local_projects = pcall(dofile, local_projects_path)

if ok and type(local_projects) == "table" then
  for _, p in ipairs(local_projects) do
    table.insert(projects, p)
  end
else
  wezterm.log_warn("Could not load local projects from " .. local_projects_path .. ": " .. tostring(local_projects))
end

local function project_selector()
  local choices = {}
  for _, p in ipairs(projects) do
    table.insert(choices, { label = p.label, id = p.path })
  end

  return wezterm.action.InputSelector {
    title = "Select Project",
    choices = choices,
    fuzzy = true,
    action = switch_workspace(function(do_switch, path, label)
      if not path then
        return
      end
      do_switch(label, { cwd = path })
    end),
  }
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
local fifo_cache = wezterm.plugin.require("https://github.com/roumail/fifo-cache")
workspace_cache = fifo_cache.new(2)
wez_tmux.apply_to_config(config)
local status_sections = {
 tabline_x = {
    -- This function checks if there is a temp message.
    -- If yes, it displays it; if no, it displays nothing (or your usual segments).
    format_notification
 },
 tabline_y = {},
 tabline_z = { "datetime" },
}
tabline.setup({sections=status_sections})
tabline.apply_to_config(config)

config.keys = remove_key(config.keys, "%", "LEADER|SHIFT")
config.keys = remove_key(config.keys, "\"", "LEADER|SHIFT")
config.keys = remove_key(config.keys, "l", "LEADER")

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
    mods = "SHIFT|CTRL",
    action = wezterm.action.CopyTo "Clipboard",
  },
  {
    key = "v",
    mods = "SHIFT|CTRL",
    action = wezterm.action.PasteFrom "Clipboard",
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
    key = "w",
    mods = "LEADER",
    action = project_selector(),
  },
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
  {
    key = "B", mods = "LEADER|SHIFT",
    action = switch_to_previous_workspace_action(),
  },

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
