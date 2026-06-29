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

