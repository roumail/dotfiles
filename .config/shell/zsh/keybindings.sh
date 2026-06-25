# bindkey '^G' list-expand prevents binding to work on mac, hence removing this here
bindkey -r '^G'

# _wezterm_zsh_preexec() {
#   local cmd="${1%% *}"
#   cmd="${cmd##*/}"
#   __wezterm_set_user_var WEZTERM_PROG "$cmd"
#   __wezterm_set_user_var WEZTERM_CMD "$1"
#   _wezterm_osc2_preexec "$1"
# }

# _wezterm_zsh_precmd() {
#   __wezterm_set_user_var WEZTERM_PROG "zsh"
#   _wezterm_osc2_precmd
#   _wezterm_osc7_hook
# }
# # remove before add to avoid duplicate hooks on reload
# add-zsh-hook -d preexec _wezterm_zsh_preexec 2>/dev/null
# add-zsh-hook -d precmd _wezterm_zsh_precmd 2>/dev/null
# add-zsh-hook preexec _wezterm_zsh_preexec
# add-zsh-hook precmd _wezterm_zsh_precmd