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
-- 17:02:46.238  INFO   logging > lua: the focus state of  0 from  default  active tab is  MuxTab(tab_id:0, pid:25128)  last active workspace was  default
local last_workspace = nil
local current_workspace = nil
local function remember_workspace(name)
  if not name then
    return
  end

  if current_workspace == nil then
    current_workspace = name
    return
  end

  if name == current_workspace then
    return
  end

  if name == last_workspace then
    current_workspace, last_workspace = last_workspace, current_workspace
    return
  end

  last_workspace = current_workspace
  current_workspace = name
end

local function sync_workspace_state(window)
  remember_workspace(window:active_workspace())
end

local function switch_workspace(window, pane, name, spawn)
  sync_workspace_state(window)

  if name == nil or name == current_workspace then
    return
  end

  remember_workspace(name)

  local action = { name = name }
  if spawn then
    action.spawn = spawn
  end

  window:perform_action(wezterm.action.SwitchToWorkspace(action), pane)
end

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
    action = wezterm.action_callback(function(window, pane, path, label)
      if not path then
        return
      end

      switch_workspace(window, pane, label, { cwd = path })
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

      -- default_cwd = "~",

      -- The default command to run, if the SpawnCommand doesn't otherwise
      -- override it.  Note that you may prefer to use `chsh` to set the
      -- default shell for your user inside WSL to avoid needing to
      -- specify it here

      default_prog = {'C:\\Windows\\System32\\wsl.exe', '--distribution', 'Debian'}
    },
  }
  config.default_domain = "WSL:Debian"
  -- config.default_prog = { 'C:\\Windows\\System32\\wsl.exe', '--distribution', 'Debian', '--cd', '~' }
end

local my_keys = {
 {
    key = "ENTER",
    mods = "ALT",
    action = wezterm.action.ToggleFullScreen
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
  -- {
  --   key = "B", mods = "LEADER|SHIFT",
  --   action = wezterm.action_callback(function(window, pane)
  --   sync_workspace_state(window)
  --   if last_workspace and last_workspace ~= current_workspace then
  --     switch_workspace(window, pane, last_workspace)
  --   end
  -- end),
-- },

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
