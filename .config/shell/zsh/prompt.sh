# Completion UX (inputrc equivalents)
zmodload zsh/complist
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z-_}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# bellstyle None
unsetopt BEEP
# Low escape-sequence timeout (inputrc keyseq-timeout 0 equivalent)
KEYTIMEOUT=1

