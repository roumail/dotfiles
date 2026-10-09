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
# Other arguments pass through to rg; later -g options override matching globs.
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
