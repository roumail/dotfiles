#!/usr/bin/env bash
# Linux-specific configuration

# Setup dircolors for colored output
eval "$(dircolors)"

eval "$(fzf --bash)"
eval "$(starship init bash)"
alias reload='source ~/.bashrc'
source_if_exists /usr/share/bash-completion/completions/git

# _append_prompt_command_once() {
#   local fn="$1"
#   [[ "$PROMPT_COMMAND" == *"$fn"* ]] && return
#   if [[ -n "$PROMPT_COMMAND" ]]; then
#     PROMPT_COMMAND="$fn; $PROMPT_COMMAND"
#   else
#     PROMPT_COMMAND="$fn"
#   fi
# }

# _wezterm_prompt_hook() {
#   # Runs when prompt is displayed
#   __wezterm_set_user_var WEZTERM_PROG "bash"
#   _wezterm_osc2_precmd
#   _wezterm_osc7_hook
# }

# # preexec runs before a command executes, thanks to trap DEBUG
# _wezterm_preexec_trap() {
#   # Skip completion context
#   [[ -n "${COMP_LINE:-}" ]] && return

#   # Ignore hook/internal commands that should not become WEZTERM_CMD
#   local -a _wezterm_ignored_patterns=(
#     "_wezterm_preexec_trap*"
#     "_wezterm_prompt_hook*"
#     "_wezterm_osc2_preexec*"
#     "_wezterm_osc2_precmd*"
#     "_wezterm_osc7_hook*"
#     "__wezterm_set_user_var*"
#     "starship_precmd*"
#   )

#   local pattern
#   for pattern in "${_wezterm_ignored_patterns[@]}"; do
#     [[ "$BASH_COMMAND" == $pattern ]] && return
#   done

#   local cmd="${BASH_COMMAND%% *}"
#   cmd="${cmd##*/}"

#   __wezterm_set_user_var WEZTERM_PROG "$cmd"
#   __wezterm_set_user_var WEZTERM_CMD "$BASH_COMMAND"
#   _wezterm_osc2_preexec "$BASH_COMMAND"
# }

# # Runs before prompt is shown
# _append_prompt_command_once "_wezterm_prompt_hook"
# trap '_wezterm_preexec_trap' DEBUG
