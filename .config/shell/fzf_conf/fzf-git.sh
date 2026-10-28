# The MIT License (MIT)
#
# Copyright (c) 2024 Junegunn Choi
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# shellcheck disable=SC2039
[[ $0 == - ]] && return

__fzf_git_color() {
  if [[ -n $NO_COLOR ]]; then
    echo never
  elif [[ $# -gt 0 ]] && [[ -n $FZF_GIT_PREVIEW_COLOR ]]; then
    echo "$FZF_GIT_PREVIEW_COLOR"
  else
    echo "${FZF_GIT_COLOR:-always}"
  fi
}

__fzf_git_cat() {
  if [[ -n $FZF_GIT_CAT ]]; then
    echo "$FZF_GIT_CAT"
    return
  fi

  # Sometimes bat is installed as batcat
  _fzf_git_bat_options="--style='${BAT_STYLE:-full}' --color=$(__fzf_git_color .) --pager=never"
  if command -v batcat > /dev/null; then
    echo "batcat $_fzf_git_bat_options"
  elif command -v bat > /dev/null; then
    echo "bat $_fzf_git_bat_options"
  else
    echo cat
  fi
}

__fzf_git_pager() {
  local pager
  pager="${FZF_GIT_PAGER:-${GIT_PAGER:-$(git config --get core.pager 2> /dev/null)}}"
  echo "${pager:-cat}"
}

if [[ $1 == --list ]]; then
  shift
  if [[ $# -eq 1 ]]; then
    # With MINE set, only branches whose last commit was authored by user.email
    branches() {
      git branch "$@" --sort=-committerdate --sort=-HEAD --format=$'%(authoremail)\t%(HEAD) %(color:yellow)%(refname:short) %(color:green)(%(committerdate:relative))\t%(color:blue)%(subject)%(color:reset)' --color=$(__fzf_git_color) |
        awk -F'\t' -v me="${MINE:+<$(git config user.email)>}" '!me || tolower($1) == tolower(me)' |
        cut -f2- | column -ts$'\t'
    }
    refs() {
      git for-each-ref "$@" --sort=-creatordate --sort=-HEAD --color=$(__fzf_git_color) --format=$'%(if:equals=refs/remotes)%(refname:rstrip=-2)%(then)%(color:magenta)remote-branch%(else)%(if:equals=refs/heads)%(refname:rstrip=-2)%(then)%(color:brightgreen)branch%(else)%(if:equals=refs/tags)%(refname:rstrip=-2)%(then)%(color:brightcyan)tag%(else)%(if:equals=refs/stash)%(refname:rstrip=-2)%(then)%(color:brightred)stash%(else)%(color:white)%(refname:rstrip=-2)%(end)%(end)%(end)%(end)\t%(color:yellow)%(refname:short) %(color:green)(%(creatordate:relative))\t%(color:blue)%(subject)%(color:reset)' | column -ts$'\t'
    }
    hashes() {
      git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=$(__fzf_git_color) "$@" $LIST_OPTS
    }
    # Locked worktrees count as archived (git wt-archive). $1 is active, archived or all.
    # Rows: path \t A (archived) or - \t display, newest commit first
    worktrees() {
      local root
      root=$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")
      awk -v view="$1" -v root="$root" -v home="$HOME" '
        function emit(  name, d) {
          if (path == "" || bare) return
          if ((view == "active" && locked) || (view == "archived" && !locked)) return
          if (path == root) name = "."
          else if (index(path, root "/") == 1) name = substr(path, length(root) + 2)
          else if (index(path, home "/") == 1) name = "~" substr(path, length(home) + 1)
          else name = path
          split(date[path], d, "\t")
          printf "%d\t%s\t%s\t\033[33m%s\033[0m \033[1m%s\033[0m%s \033[32m%s\033[0m \033[2m%s\033[0m\n", \
            d[1], path, (locked ? "A" : "-"), (locked ? "A" : " "), name, \
            (branch == name ? "" : " \033[36m[" branch "]\033[0m"), d[2], reason
        }
        FNR == NR { split($0, f, "\t"); date[f[1]] = f[2] "\t" f[3]; next }
        /^worktree / { emit(); path = substr($0, 10); branch = ""; bare = locked = 0; reason = ""; next }
        /^branch /   { branch = substr($0, 19); next }
        /^detached/  { branch = "detached"; next }
        /^bare/      { bare = 1; next }
        /^locked/    { locked = 1; reason = substr($0, 8); next }
        END { emit() }
      ' <(git for-each-ref --format=$'%(worktreepath)\t%(committerdate:unix)\t%(committerdate:relative)' refs/heads) \
        <(git worktree list --porcelain) |
        sort -t$'\t' -k1,1nr | cut -f2-
    }
    case "$1" in
      branches|local-branches)
        echo 'CTRL-O (open in browser) ╱ ALT-A (local/all) ╱ ALT-M (mine/everyone)'
        echo 'ALT-H (list commit hashes) ╱ CTRL-X (delete) ╱ ALT-D (delete merged)'
        branches
        ;;
      all-branches)
        echo 'CTRL-O (open in browser) ╱ ALT-ENTER (accept without remote) ╱ ALT-A (local/all) ╱ ALT-M (mine/everyone)'
        echo 'ALT-H (list commit hashes) ╱ CTRL-X (delete) ╱ ALT-D (delete merged)'
        branches -a
        ;;
      hashes)
        echo 'CTRL-O (open in browser) ╱ CTRL-D (diff) ╱ CTRL-S (toggle sort)'
        echo 'ALT-R (toggle raw mode) ╱ ALT-F (list files) ╱ ALT-A (show all hashes)'
        hashes
        ;;
      all-hashes)
        echo 'CTRL-O (open in browser) ╱ CTRL-D (diff)'
        echo 'CTRL-S (toggle sort) ╱ ALT-F (list files)'
        hashes --all
        ;;
      refs)
        echo 'CTRL-O (open in browser) ╱ ALT-E (examine in editor) ╱ ALT-A (show all refs)'
        refs --exclude='refs/remotes'
        ;;
      all-refs)
        echo 'CTRL-O (open in browser) ╱ ALT-E (examine in editor)'
        refs
        ;;
      active-worktrees|archived-worktrees|all-worktrees)
        worktrees "${1%-worktrees}"
        ;;
      *) exit 1 ;;
    esac
  elif [[ $# -gt 1 ]]; then
    set -e

    branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
    if [[ $branch == HEAD ]]; then
      branch=$(git describe --exact-match --tags 2> /dev/null || git rev-parse --short HEAD)
    fi

    # Only supports GitHub for now
    case "$1" in
      commit)
        hash=$(grep -o "[a-f0-9]\{7,\}" <<< "$2" | head -n 1)
        path=/commit/$hash
        ;;
      branch|remote-branch)
        branch=$(sed 's/^[* ]*//' <<< "$2" | cut -d' ' -f1)
        remote=$(git config branch."${branch}".remote || echo 'origin')
        branch=${branch#$remote/}
        path=/tree/$branch
        ;;
      remote)
        remote=$2
        path=/tree/$branch
        ;;
      file) path=/blob/$branch/$(git rev-parse --show-prefix)$2 ;;
      tag)  path=/releases/tag/$2 ;;
      *)    exit 1 ;;
    esac

    remote=${remote:-$(git config branch."${branch}".remote || echo 'origin')}
    remote_url=$(git remote get-url "$remote" 2> /dev/null || echo "$remote")

    if [[ $remote_url =~ ^git@ ]]; then
      url=${remote_url%.git}
      url=${url#git@}
      url=https://${url/://}
    elif [[ $remote_url =~ ^http ]]; then
      url=${remote_url%.git}
    fi

    case "$OSTYPE" in
      darwin*)
        open "$url$path"
        ;;
      msys)
        # Git-Bash on Windows
        start "$url$path"
        ;;
      linux*)
        # Handle WSL on Windows
        if uname -a | grep -i -q Microsoft && command -v powershell.exe; then
          powershell.exe -NoProfile start "$url$path"
        else
          xdg-open "$url$path"
        fi
        ;;
      *)
        # fall back to xdg-open for BSDs, etc.
        xdg-open "$url$path"
        ;;
    esac
    exit 0
  fi
fi

if [[ $- =~ i ]] || [[ $1 = --run ]]; then # ----------------------------------

if [[ $__fzf_git_fzf ]]; then
  eval "$__fzf_git_fzf"
else
  # Redefine this function to change the options
  _fzf_git_fzf() {
    fzf --height 50% --tmux 90%,70% \
      --layout reverse --multi --min-height 20+ --border \
      --no-separator --header-border horizontal \
      --border-label-pos 2 \
      --color 'label:blue' \
      --preview-window 'right,50%' --preview-border line \
      --bind 'ctrl-/:change-preview-window(down,50%|hidden|)' "$@"
  }
fi

_fzf_git_check() {
  git rev-parse > /dev/null 2>&1 && return

  [[ -n $TMUX ]] && tmux display-message "Not in a git repository"
  return 1
}

__fzf_git=${BASH_SOURCE[0]:-${(%):-%x}}
__fzf_git=$(readlink -f "$__fzf_git" 2> /dev/null || /usr/bin/ruby --disable-gems -e 'puts File.expand_path(ARGV.first)' "$__fzf_git" 2> /dev/null)

_fzf_git_files() {
  _fzf_git_check || return
  local root query extract_file_name
  root=$(git rev-parse --show-toplevel)
  [[ -n "$(git rev-parse --show-prefix)" ]] && query='!../ '

  read -r -d "" extract_file_name <<'EOF'
"$(cut -c4- <<< {} | sed 's/.* -> //;s/^"//;s/"$//;s/\\"/"/g')"
EOF

  (
    git -c core.quotePath=false -c color.status=$(__fzf_git_color) status --short --no-branch --untracked-files=all
    git -c core.quotePath=false ls-files "$root" | grep -vxFf <(
      git -c core.quotePath=false status --short --untracked-files=no |
        cut -c4- | sed -e 's/.* -> //' -e '/^"[^"\\]*"$/ { s/^"//;s/"$//; }'
      echo :
    ) | sed 's/^/   /'
  ) |
    _fzf_git_fzf -m --ansi --nth 2..,.. \
      --border-label '📁 Files ' \
      --header 'CTRL-O (open in browser) ╱ ALT-E (open in editor)' \
      --bind "ctrl-o:execute-silent:bash \"$__fzf_git\" --list file $extract_file_name" \
      --bind "alt-e:execute:${EDITOR:-vim} $extract_file_name" \
      --query "$query" \
      --preview "git -c core.quotePath=false diff --no-ext-diff --color=$(__fzf_git_color .) -- $extract_file_name | $(__fzf_git_pager); $(__fzf_git_cat) $extract_file_name" "$@" |
    cut -c4- | sed 's/.* -> //'
}

_fzf_git_tree_files() {
  _fzf_git_check || return

  local treeish
  for treeish in "$@"; do
    git diff-tree --no-commit-id --name-only "$treeish" -r
  done | sort -u |
    _fzf_git_fzf -m \
      --border-label "📂 Files in $* " \
      --header 'CTRL-O (open in browser) ╱ ALT-E (open in editor)' \
      --bind "ctrl-o:execute-silent:bash \"$__fzf_git\" --list file {}" \
      --bind "alt-e:execute:${EDITOR:-vim} {}" \
      --preview "git -c core.quotePath=false diff --no-ext-diff --color=$(__fzf_git_color .) -- {} | $(__fzf_git_pager); $(__fzf_git_cat) {}"
}

_fzf_git_branches() {
  _fzf_git_check || return

  local shell
  [[ -n ${BASH_VERSION:-} ]] && shell=bash || shell=zsh

  # The prompt names the view (local or all, +mine), so reloads keep showing it.
  # CTRL-X asks before forcing an unmerged branch; stty as in _fzf_git_worktrees.
  local list="p=\${FZF_PROMPT%> }; MINE=\${p#\${p%+mine}} bash '$__fzf_git' --list \${p%+mine}-branches"
  local ask="stty echo icanon </dev/tty >/dev/tty 2>/dev/null; read -r a"
  bash "$__fzf_git" --list branches |
  __fzf_git_fzf=$(declare -f _fzf_git_fzf) _fzf_git_fzf --ansi \
    --border-label '🌲 Branches ' \
    --prompt 'local> ' \
    --header-lines 2 \
    --tiebreak begin \
    --preview-window down,border-top,40% \
    --color hl:underline,hl+:underline \
    --no-hscroll \
    --bind 'ctrl-/:change-preview-window(down,70%|hidden|)' \
    --bind "ctrl-o:execute-silent:bash \"$__fzf_git\" --list branch {}" \
    --bind "alt-a:transform-prompt~p=\${FZF_PROMPT%> }; case \$p in all*) echo \"local\${p#all}> \" ;; *) echo \"all\${p#local}> \" ;; esac~+reload:$list" \
    --bind "alt-m:transform-prompt~p=\${FZF_PROMPT%> }; case \$p in *+mine) echo \"\${p%+mine}> \" ;; *) echo \"\$p+mine> \" ;; esac~+reload:$list" \
    --bind "ctrl-x:execute~for b in \$(printf '%s\n' {+} | cut -c3- | cut -d' ' -f1); do git show-ref -q --verify \"refs/heads/\$b\" || { echo \"skip \$b: not a local branch\"; continue; }; git branch -d \"\$b\" && continue; printf 'Force delete %s? [y/N] ' \"\$b\"; $ask; [ \"\$a\" = y ] && git branch -D \"\$b\"; done~+reload:$list" \
    --bind "alt-d:execute~git dmb; printf 'Press enter '; $ask~+reload:$list" \
    --bind "alt-h:become:LIST_OPTS=\$(cut -c3- <<< {} | cut -d' ' -f1) $shell \"$__fzf_git\" --run hashes" \
    --bind "alt-enter:become:printf '%s\n' {+} | cut -c3- | sed 's@[^/]*/@@'" \
    --preview "git log --oneline --graph --date=short --color=$(__fzf_git_color .) --pretty='format:%C(auto)%cd %h%d %s' \$(cut -c3- <<< {} | cut -d' ' -f1) --" "$@" |
  sed 's/^\* //' | awk '{print $1}' # Slightly modified to work with hashes as well
}

_fzf_git_tags() {
  _fzf_git_check || return
  git tag --sort -version:refname |
  _fzf_git_fzf --preview-window right,70% \
    --border-label '📛 Tags ' \
    --header 'CTRL-O (open in browser)' \
    --bind "ctrl-o:execute-silent:bash \"$__fzf_git\" --list tag {}" \
    --bind 'alt-r:toggle-raw' \
    --preview "git show --color=$(__fzf_git_color .) {} | $(__fzf_git_pager)" "$@"
}

_fzf_git_hashes() {
  _fzf_git_check || return
  bash "$__fzf_git" --list hashes |
  _fzf_git_fzf --ansi --no-sort --bind 'ctrl-s:toggle-sort,alt-r:toggle-raw' \
    --border-label '🍡 Hashes ' \
    --header-lines 2 \
    --bind "ctrl-o:execute-silent:bash \"$__fzf_git\" --list commit {}" \
    --bind "ctrl-d:execute:grep -o '[a-f0-9]\{7,\}' <<< {} | head -n 1 | xargs git diff --color=$(__fzf_git_color) > /dev/tty" \
    --bind "alt-a:change-border-label(🍇 All hashes)+reload:bash \"$__fzf_git\" --list all-hashes" \
    --bind "alt-f:become:echo ::tree_files;
      awk 'match(\$0, /[a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9]*/) { print substr(\$0, RSTART, RLENGTH) }' {+f} |
        xargs bash \"$__fzf_git\" --run tree_files" \
    --color hl:underline,hl+:underline \
    --preview "grep -o '[a-f0-9]\{7,\}' <<< {} | head -n 1 | xargs git show --color=$(__fzf_git_color .) | $(__fzf_git_pager)" "$@" |
  awk '
    NR==1 && $0=="::tree_files" {
      mode="tree_files"
      next
    }

    mode=="tree_files" {
      print
      next
    }

    match($0, /[a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9]*/) {
      print substr($0, RSTART, RLENGTH)
    }
  '
}

_fzf_git_remotes() {
  _fzf_git_check || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  _fzf_git_fzf --tac \
    --border-label '📡 Remotes ' \
    --header 'CTRL-O (open in browser)' \
    --bind "ctrl-o:execute-silent:bash \"$__fzf_git\" --list remote {1}" \
    --preview-window right,70% \
    --preview "git log --oneline --graph --date=short --color=$(__fzf_git_color .) --pretty='format:%C(auto)%cd %h%d %s' '{1}/$(git rev-parse --abbrev-ref HEAD)' --" "$@" |
  cut -d$'\t' -f1
}

_fzf_git_stashes() {
  _fzf_git_check || return
  git stash list | _fzf_git_fzf \
    --border-label '🥡 Stashes ' \
    --header 'CTRL-X (drop stash)╱ CTRL-A (apply stash)' \
    --bind 'ctrl-x:reload(git stash drop -q {1}; git stash list)' \
    --bind 'ctrl-A:execute(git stash apply {1})' \
    -d: --preview "git show --first-parent --color=$(__fzf_git_color .) {1} | $(__fzf_git_pager)" "$@" |
  cut -d: -f1
}

_fzf_git_lreflogs() {
  _fzf_git_check || return
  git reflog --color=$(__fzf_git_color) --format="%C(blue)%gD %C(yellow)%h%C(auto)%d %gs" | _fzf_git_fzf --ansi \
    --border-label '📒 Reflogs ' \
    --bind 'alt-r:toggle-raw' \
    --preview "git show --color=$(__fzf_git_color .) {1} | $(__fzf_git_pager)" "$@" |
  awk '{print $1}'
}

_fzf_git_each_ref() {
  _fzf_git_check || return
  bash "$__fzf_git" --list refs | _fzf_git_fzf --ansi \
    --nth 2,2.. \
    --tiebreak begin \
    --border-label '☘️  Each ref ' \
    --header-lines 1 \
    --preview-window down,border-top,40% \
    --color hl:underline,hl+:underline \
    --no-hscroll \
    --bind 'ctrl-/:change-preview-window(down,70%|hidden|)' \
    --bind "ctrl-o:execute-silent:bash \"$__fzf_git\" --list {1} {2}" \
    --bind "alt-e:execute:${EDITOR:-vim} <(git show {2}) < /dev/tty > /dev/tty" \
    --bind "alt-a:change-border-label(🍀 Every ref)+reload:bash \"$__fzf_git\" --list all-refs" \
    --preview "git log --oneline --graph --date=short --color=$(__fzf_git_color .) --pretty='format:%C(auto)%cd %h%d %s' {2} --" "$@" |
  awk '{print $2}'
}

_fzf_git_worktrees() {
  _fzf_git_check || return
  # The prompt names the view, so reloads keep showing it.
  # From the CTRL-G widget the terminal is in zle's mode, without echo; ALT-S turns it on for read.
  local list="bash '$__fzf_git' --list \"\${FZF_PROMPT%> }-worktrees\""
  bash "$__fzf_git" --list active-worktrees | _fzf_git_fzf --ansi \
    --border-label '🌴 Worktrees ' \
    --prompt 'active> ' \
    --delimiter '\t' --with-nth 3.. \
    --header 'ALT-A (active/archived/all) ╱ ALT-S (archive/unarchive) ╱ CTRL-X (remove worktree)' \
    --bind "alt-a:transform:case \$FZF_PROMPT in active*) v=archived ;; archived*) v=all ;; *) v=active ;; esac; echo \"change-prompt(\$v> )+reload:bash '$__fzf_git' --list \$v-worktrees\"" \
    --bind "alt-s:execute~if [ {2} = A ]; then git wt-unarchive {1}; else printf 'Archive reason: '; stty echo icanon </dev/tty >/dev/tty 2>/dev/null; read -r r; git wt-archive {1} \"\$r\"; fi~+reload($list)" \
    --bind "ctrl-x:reload:git worktree remove {1} > /dev/null; $list" \
    --preview "
      git -c color.status=$(__fzf_git_color .) -C {1} status --short --branch
      echo
      git -C {1} log --oneline --graph --date=short --color=$(__fzf_git_color .) --pretty='format:%C(auto)%cd %h%d %s' HEAD --
    " "$@" |
  cut -f1
}

_fzf_git_list_bindings() {
  cat <<'EOF'

CTRL-G ? to show this list
CTRL-G CTRL-F for Files
CTRL-G CTRL-B for Branches
CTRL-G CTRL-T for Tags
CTRL-G CTRL-R for Remotes
CTRL-G CTRL-H for commit Hashes
CTRL-G CTRL-S for Stashes
CTRL-G CTRL-L for reflogs
CTRL-G CTRL-W for Worktrees
CTRL-G CTRL-E for Each ref (git for-each-ref)
EOF
}

fi # --------------------------------------------------------------------------

if [[ $1 = --run ]]; then
  shift
  type=$1
  shift
  eval "_fzf_git_$type" "$@"

elif [[ $- =~ i ]]; then # ------------------------------------------------------
if [[ -n "${BASH_VERSION:-}" ]]; then
  __fzf_git_init() {
    bind -m emacs-standard '"\er":  redraw-current-line'
    bind -m emacs-standard '"\C-z": vi-editing-mode'
    bind -m vi-command     '"\C-z": emacs-editing-mode'
    bind -m vi-insert      '"\C-z": emacs-editing-mode'

    local o c
    for o in "$@"; do
      c=${o:0:1}
      if [[ $c == '?' ]]; then
        bind -x "\"\C-g$c\": _fzf_git_list_bindings"
        continue
      fi
      bind -m emacs-standard '"\C-g\C-'$c'": " \C-u \C-a\C-k`_fzf_git_'$o'`\e\C-e\C-y\C-a\C-y\ey\C-h\C-e\er \C-h"'
      bind -m vi-command     '"\C-g\C-'$c'": "\C-z\C-g\C-'$c'\C-z"'
      bind -m vi-insert      '"\C-g\C-'$c'": "\C-z\C-g\C-'$c'\C-z"'
      bind -m emacs-standard '"\C-g'$c'":    " \C-u \C-a\C-k`_fzf_git_'$o'`\e\C-e\C-y\C-a\C-y\ey\C-h\C-e\er \C-h"'
      bind -m vi-command     '"\C-g'$c'":    "\C-z\C-g'$c'\C-z"'
      bind -m vi-insert      '"\C-g'$c'":    "\C-z\C-g'$c'\C-z"'
    done
  }
elif [[ -n "${ZSH_VERSION:-}" ]]; then
  __fzf_git_join() {
    local item
    while read -r item; do
      echo -n -E "${(q)${(Q)item}} "
    done
  }

  __fzf_git_init() {
    setopt localoptions no_glob
    local m o
    for o in "$@"; do
      if [[ ${o[1]} == "?" ]];then
        eval "fzf-git-$o-widget() { zle -M '$(_fzf_git_list_bindings)' }"
      else
        eval "fzf-git-$o-widget() { local result=\$(_fzf_git_$o | __fzf_git_join); zle reset-prompt; LBUFFER+=\$result }"
      fi
      eval "zle -N fzf-git-$o-widget"
      for m in emacs vicmd viins; do
        eval "bindkey -M $m '^g^${o[1]}' fzf-git-$o-widget"
        eval "bindkey -M $m '^g${o[1]}' fzf-git-$o-widget"
      done
    done
  }
fi
__fzf_git_init files branches tags remotes hashes stashes lreflogs each_ref worktrees '?list_bindings'

fi # --------------------------------------------------------------------------
