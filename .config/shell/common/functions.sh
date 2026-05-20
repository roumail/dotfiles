#!/usr/bin/env bash
chkpyt() {
    PYTEST_ADDOPTS='' pytest -q -r fE --tb=no --capture=fd "$@"
}

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
}

__wezterm_custom_preexec() {
  [[ -z "$1" ]] && return
  local cmd="${1%% *}"
  cmd="${cmd##*/}"
  __wezterm_set_user_var WEZTERM_PROG "$cmd"
  __wezterm_set_user_var WEZTERM_CMD "$1"
}

precmd_functions+=(__wezterm_custom_precmd)
preexec_functions+=(__wezterm_custom_preexec)
# _wezterm_osc7_hook() {
#     printf "\033]7;file://%s%s\a" "$HOSTNAME" "$PWD"
#     __wezterm_set_user_var WEZTERM_CWD "$PWD"
# }

# _wezterm_osc2_preexec() {
#     printf "\033]2;%s\a" "$1"
# }

# _wezterm_osc2_precmd() {
#     printf "\033]2;%s\a" "$PWD"
# }
