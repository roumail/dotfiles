-- ~/.config/wezterm/?.lua
local wezterm = require 'wezterm'
local M = {}

function M.remove_key(keys, key, mods)
  local result = {}
  for _, k in ipairs(keys) do
    if not (k.key == key and k.mods == mods) then
      table.insert(result, k)
    end
  end
  return result
end

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

function M.processed_name(tab)
  local title = tab.tab_title
  local pane = tab.active_pane
  local vars = pane.user_vars
  local process = vars and vars.WEZTERM_PROG
  -- If tab has a custom title, use it
  if title and title ~= "" then
    return wezterm.format({
      { Text = title }
    })
  end

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

function M.resize_pane(key, direction)
  return {
    key = key,
    action = wezterm.action.AdjustPaneSize { direction, 3 }
  }
end
return M
