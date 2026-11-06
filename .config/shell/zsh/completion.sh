# Completion system: without compinit zsh falls back to its built-in
# completion, which offers plain files for every command (even cd)
autoload -Uz compinit && compinit

# Completion UX (inputrc equivalents)
zmodload zsh/complist
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z-_}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# cd lists only active worktrees in a <repo>wt/ root: archived ones (git
# wt-archive locks them) complete once their name is the only match.
zstyle -e ':completion:*:*:cd:*' ignored-patterns '
  local dir=${${(M)PREFIX:#*/*}:+${PREFIX%/*}} lock=
  reply=()
  for lock in ${~dir:-.}/.bare/worktrees/*/locked(N); do
    reply+=("(*/)#${${$(<${lock:h}/gitdir):h}:t}")
  done'
