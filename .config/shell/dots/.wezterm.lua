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
      if not path then return end -- User pressed Escape

      window:perform_action(
        wezterm.action.SwitchToWorkspace {
          name = label, -- Use the label as the workspace name
          spawn = { cwd = path },
        },
        pane
      )
    end),
  }
end

-- config.color_scheme = 'Batman'
config.font_size = 12
config.font = wezterm.font 'JetBrains Mono'
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }
config.window_close_confirmation = 'NeverPrompt'
config.disable_default_key_bindings = true

-- load plugin
local wez_tmux = require("plugins.wez-tmux.plugin")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
wez_tmux.apply_to_config(config)
local status_sections = {
 tabline_x = {},
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

      -- The default command to run, if the SpawnCommand doesn't otherwise
      -- override it.  Note that you may prefer to use `chsh` to set the
      -- default shell for your user inside WSL to avoid needing to
      -- specify it here

      -- default_prog = {"fish"}
    },
  }
  config.default_domain = "WSL:Debian"
  -- config.default_prog = { 'C:\\Windows\\System32\\wsl.exe', '--distribution', 'Debian', '--cd', '~' }
end

local my_keys = {
  {
    key = "c",
    mods = "LEADER",
    action = wezterm.action.CopyTo "Clipboard",
  },
  {
    key = "p",
    mods = "LEADER",
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
