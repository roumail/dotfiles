#!/usr/bin/env bash

# https://wezterm.org/recipes/passing-data.html?h=osc#user-vars
__wezterm_set_user_var() {
    command -v base64 >/dev/null 2>&1 || return 0

    local name="$1"
    local value="$2"
    local encoded
    encoded="$(printf "%s" "$value" | base64 | tr -d '\r\n')"

    if [[ -z "${TMUX:-}" ]]; then
        printf '\033]1337;SetUserVar=%s=%s\007' "$name" "$encoded"
    else
        printf '\033Ptmux;\033\033]1337;SetUserVar=%s=%s\007\033\\' "$name" "$encoded"
    fi
}

__wezterm_custom_precmd() {
  __wezterm_set_user_var WEZTERM_CWD "$PWD"
  if [[ -n "${ZSH_NAME-}" ]]; then
    __wezterm_set_user_var WEZTERM_PROG "zsh"
  elif [[ -n "${BASH_VERSION-}" ]]; then
    __wezterm_set_user_var WEZTERM_PROG "bash"
  fi
}

__wezterm_custom_preexec() {
  [[ -z "$1" ]] && return

  local typed="${1%% *}"
  local resolved="$typed"

  # resolve aliases
  if alias "$typed" >/dev/null 2>&1; then
    resolved="$(alias "$typed")"

    # alias v='vim .'
    resolved="${resolved#*=}"
    resolved="${resolved//\'}"
    resolved="${resolved%% *}"
  fi

  # normalize basename
  resolved="${resolved##*/}"

  # resolve shell functions that wrap a program
  case "$resolved" in
    v) resolved="vim" ;;
  esac

  __wezterm_set_user_var WEZTERM_PROG "$resolved"
  __wezterm_set_user_var WEZTERM_CMD "$1"
}

# Open vim on changed git files (fzf GFiles?), or the current dir when outside
# a repo or the tree is clean
unalias v 2>/dev/null
v() {
  if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    vim -c 'GFiles?'
  else
    vim .
  fi
}

precmd_functions+=(__wezterm_custom_precmd)
preexec_functions+=(__wezterm_custom_preexec)
