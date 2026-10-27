# bindkey '^G' list-expand prevents binding to work on mac, hence removing this here
bindkey -r '^G'

# TAB cycles through completions (menu-complete)
bindkey '^I'    menu-complete
bindkey '^[[Z'  reverse-menu-complete
# Arrow keys: history prefix search (history-search-backward/forward)
bindkey '^[[A'  history-beginning-search-backward
bindkey '^[[B'  history-beginning-search-forward
# Alt+Backspace: delete last path component (unix-filename-rubout)
bindkey '\e^?'  backward-kill-word
# Alt+d: delete next word (kill-word); vi insert mode has no binding for it
bindkey '\ed'   kill-word

# ai and aid (common/functions.sh) take the rest of the line as typed, as
# :Ai does in Vim: unquoted, zsh would end it at a #source
# (interactivecomments), wait at an apostrophe and glob a ?. Quoted whole
# before it runs; a line recalled from history is quoted already.
function _ai_raw_line {
  [[ $BUFFER =~ '^(aid?) +(.*[^ ])' ]] || return 0
  local rest=$match[2]
  [[ ${(qq)${(Q)rest}} == "$rest" ]] || BUFFER="$match[1] ${(qq)rest}"
}
# Once, before zsh-vi-mode's init, which keeps this zle-line-finish inside
# its own; again (from zvm_after_init) it would replace zsh-vi-mode's
autoload -Uz add-zle-hook-widget
() {
  local hooks
  zstyle -a zle-line-finish widgets hooks
  [[ " ${hooks[*]} " == *:_ai_raw_line\ * ]] || add-zle-hook-widget line-finish _ai_raw_line
}

