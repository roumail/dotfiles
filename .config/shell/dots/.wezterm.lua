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
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
local wez_sb_alert= wezterm.plugin.require("https://github.com/roumail/wez-status-bar-alert")
local wez_ws_alt = wezterm.plugin.require("https://github.com/roumail/wez-workspace-alt")
-- local wez_ws_alt = require("plugins.wez-workspace-alt.plugin")
-- local fifo_cache = require("plugins.fifo-cache.plugin")
wez_tmux.apply_to_config(config)
wez_ws_alt.apply_to_config(config)

wezterm.on("window-config-reloaded", function(window, pane)
  wez_sb_alert.notify("Config reloaded")
end)

local icons =  {
  ['default'] = wezterm.nerdfonts.md_application,
  ['git'] = wezterm.nerdfonts.dev_git,
  ['lua'] = wezterm.nerdfonts.seti_lua,
  ['zsh'] = wezterm.nerdfonts.dev_terminal,
  ['bash'] = wezterm.nerdfonts.cod_terminal_bash,
  ['python'] = wezterm.nerdfonts.dev_python,
  ['tmux'] = wezterm.nerdfonts.cod_terminal_tmux,
  ['vim'] = wezterm.nerdfonts.dev_vim,
}

local function shorten(path)
  path = path:gsub("^file://", "")
  local home = wezterm.home_dir
  if path:sub(1, #home) == home then
    path = "~" .. path:sub(#home + 1)
  end
  local parts = {}
  for part in path:gmatch("[^/]+") do
    table.insert(parts, part)
  end

  if #parts == 0 then
    return path
  end

  local leaf = parts[#parts]
  local special = {
    main = { depth = 3, label = "m" },
    master = { depth = 3, label = "m" },
  }

  local config = special[leaf]

  local keep_segments = (config and config.depth)
  or (#leaf > 12 and 2 or 1)
  if #parts <= keep_segments then
    if config then
      parts[#parts] = config.label
      return table.concat(parts, "/")
    end
    return path
  end

  local tail_start = #parts - keep_segments + 1
  local tail_parts = {}
  for i = tail_start, #parts do
    table.insert(tail_parts, parts[i])
  end
  if config then
    tail_parts[#tail_parts] = config.label
  end

  local tail = table.concat(tail_parts, "/")

  if parts[1] == "~" then
    return "~/" .. "…/" .. tail
  end

  return "…/" .. tail
end

local function processed_name(tab)
  local pane = tab.active_pane
  local vars = pane.user_vars
  local process = vars and vars.WEZTERM_PROG
  if not process or process == "" then
    return wezterm.format({
      { Text = icons.default }
    })
  end
  local icon = icons[process] or icons.default
  local cwd = pane.current_working_dir and pane.current_working_dir.file_path or ""
  if cwd ~= "" then
    local shortened = shorten(cwd)
    return wezterm.format({
      { Text = icon .. " " .. shortened }
    })
  end

  return wezterm.format({
    { Text = icon .. " " .. process }
  })
end

local status_sections = {
  tab_active = {
    'index',
    processed_name ,
    { 'zoomed', padding = 0 },
  },
  tab_inactive = { 'index',  processed_name },
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
config.keys = remove_key(config.keys, "l", "LEADER")
config.keys = remove_key(config.keys, "s", "LEADER")
config.keys = remove_key(config.keys, "x", "LEADER")
config.keys = remove_key(config.keys, "&", "LEADER|SHIFT")
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

local function resize_pane(key, direction)
  return {
    key = key,
    action = wezterm.action.AdjustPaneSize { direction, 3 }
  }
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
    resize_pane('j', 'Down'),
    resize_pane('k', 'Up'),
    resize_pane('h', 'Left'),
    resize_pane('l', 'Right'),
}

-- config.key_tables.copy_mode = config.key_tables.copy_mode or {}
-- table.insert(config.key_tables.copy_mode, {
--   key = 'x',
--   mods = 'NONE',
--   action = wezterm.action.CopyMode { MoveForwardZoneOfType = 'Prompt' },
--   action = wezterm.action.CopyMode { MoveForwardZoneOfType = 'Output' },
--   action = wezterm.action.CopyMode { MoveForwardZoneOfType = 'Input' },
--   action = wezterm.action.CopyMode { MoveBackwardZoneOfType = 'Prompt' },
--   action = wezterm.action.CopyMode { MoveBackwardZoneOfType = 'Output' },
--   action = wezterm.action.CopyMode { MoveBackwardZoneOfType = 'Input' },
--   action = wezterm.action.CopyMode { SetSelectionMode = 'Cell' },
--   action = wezterm.action.CopyMode 'MoveBackwardSemanticZone'
--   action = wezterm.action.CopyMode 'MoveForwardSemanticZone'
--   -- action = wezterm.action.CopyMode { SetSelectionMode = 'SemanticZone' },
-- })

for _, key in ipairs(my_keys) do
  table.insert(config.keys, key)
end

return config
