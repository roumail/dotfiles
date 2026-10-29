#!/usr/bin/env bash

# Wider ripgrep search with machine-local defaults in local/functions.sh:
#   RG_WIDE_EXCLUDES=('gecowt/**' 'another-project/**')
#   RG_WIDE_EXCLUDE_TESTS=true
# Without configuration, no projects are excluded and tests are excluded.
# Git metadata is always filtered; normal ripgrep ignore behavior is unchanged.
# Put wrapper flags before ripgrep arguments:
#   rgwide --exclude-dirs octopus --exclude-dirs configuration rename
#   rgwide --include-dirs gecowt --include-tests -F \
#     '@session_event_listener(Session, "before_flush", Asset)' \
#     bluesnake gecowt/master
# --include-dirs DIR removes the matching DIR/** default exclusion, not other
# search roots. --exclude-dirs DIR adds an exclusion and takes precedence.
# Both directory flags are repeatable and accept an optional trailing slash.
# --all-projects skips default exclusions, but keeps explicit ones.
# --include-tests / --exclude-tests override the local default; last flag wins.
# --wide-help shows only rgwide help; --help shows it followed by rg's help.
# Other arguments pass through to rg; later -g options override matching globs.
__rgwide_help() {
  cat <<'EOF'
Usage: rgwide [WRAPPER OPTIONS] [RG ARGUMENTS...]

Wrapper options (must come before ripgrep arguments):
  --include-dirs DIR   Remove the DIR/** default exclusion (repeatable)
  --exclude-dirs DIR   Add a DIR/** exclusion; takes precedence (repeatable)
  --all-projects       Skip default RG_WIDE_EXCLUDES, keep explicit exclusions
  --include-tests      Search tests/ directories
  --exclude-tests      Skip tests/ directories (last test flag wins)
  --wide-help          Show only this help
  --help               Show this help, then rg's help

Config: RG_WIDE_EXCLUDES=('proj/**' ...), RG_WIDE_EXCLUDE_TESTS=true|false
EOF
}

rgwide() {
  local glob directory include skip
  local exclude_tests="${RG_WIDE_EXCLUDE_TESTS:-true}"
  local all_projects=false
  local -a args=()
  local -a include_dirs=()
  local -a exclude_dirs=()
  case "$exclude_tests" in
    true|false) ;;
    *)
      printf 'rgwide: RG_WIDE_EXCLUDE_TESTS must be true or false\n' >&2
      return 2
      ;;
  esac
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --wide-help|--help)
        __rgwide_help
        if [ "$1" = --help ]; then
          printf '\n--- rg --help ---\n'
          command rg --help
        fi
        return 0
        ;;
      --include-tests) exclude_tests=false ;;
      --exclude-tests) exclude_tests=true ;;
      --all-projects) all_projects=true ;;
      --include-dirs|--exclude-dirs)
        if [ "$#" -lt 2 ] || [ -z "$2" ] || [[ "$2" == -* ]]; then
          printf 'rgwide: %s requires a directory argument\n' "$1" >&2
          return 2
        fi
        directory="${2%/}"
        if [ "$1" = --include-dirs ]; then
          include_dirs+=("$directory/**")
        else
          exclude_dirs+=("$directory/**")
        fi
        shift
        ;;
      *) break ;;
    esac
    shift
  done
  if [ "$all_projects" = false ]; then
    for glob in "${RG_WIDE_EXCLUDES[@]}"; do
      [ -n "$glob" ] || continue
      skip=false
      for include in "${include_dirs[@]}"; do
        if [ "$glob" = "$include" ]; then
          skip=true
          break
        fi
      done
      if [ "$skip" = false ]; then
        args+=(-g "!$glob")
      fi
    done
  fi
  for glob in "${exclude_dirs[@]}"; do
    args+=(-g "!$glob")
  done
  args+=(-g '!**/.git/**')
  if [ "$exclude_tests" = true ]; then
    args+=(-g '!**/tests/**')
  fi
  command rg "${args[@]}" "$@"
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

# Open vim on the fugitive status window, or the current dir when outside a
# repo or the tree is clean. The status window opens over netrw for the current
# dir, so closing it leaves netrw instead of an empty buffer.
unalias v 2>/dev/null
v() {
  if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    vim . -c 'Git'
  else
    vim .
  fi
}

precmd_functions+=(__wezterm_custom_precmd)
preexec_functions+=(__wezterm_custom_preexec)

# ai: start your coding agent (claude or copilot) in Vim, given your
# vim-prompts rules first, the way `claude` alone never is. Run it in the
# folder or repository to work on:
#   ai                         the rules, then it waits for your question
#   ai why is the build slow   the rules and your question
#   ai /review #changes        a persona instead of /default, a #source
#   ai @README.md tidy this    files to read, as :Ai takes them
# aid takes the same and opens the prompt in :AiDraft to write in; :wq sends.
# #comments has nothing here: review comments live in a running Vim
# (:Comment, :CommentsLoad), and this Vim is new. Use :Ai in that Vim.
# In zsh the rest of the line goes as typed, as in Vim: no quoting, an
# apostrophe or a ? is fine (zsh/keybindings.sh). In bash, quote it.
# Ctrl-D or /exit ends the agent, then :q leaves Vim.
ai() { _ai Ai "$@"; }
aid() { _ai AiDraft "$@"; }
_ai() {
  local cmd=$1
  shift
  # `vim .` rather than a bare vim: Fugitive finds the repository from a
  # buffer, and #changes and #diff_pairs have nothing without one.
  case "${1:-}" in
    /*) vim . +"$cmd $*" ;;
    *) vim . +"$cmd /default $*" ;;
  esac
}

# rv [branch]: review in a free scratch worktree (git wt-review). A branch
# goes straight to /review; none opens :PRs on the default branch to pick one.
rv() {
  local dir
  dir=$(git wt-review "$@") && cd "$dir" || return
  if [ -n "${1:-}" ]; then ai /review; else vim . +PRs; fi
}
