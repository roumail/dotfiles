#!/usr/bin/env bash
chkpyt() {
    PYTEST_ADDOPTS='' pytest -q -r fE --tb=no --capture=fd "$@"
}


source_dir() {
  [ -d "$1" ] || return
  find "$1" -maxdepth 1 -name '*.sh' -type f | while read -r f; do
      source_if_exists "$f"
  done
}

# Git worktree helper functions
git_get_bare_dir() {
    local bare_dir=$(git rev-parse --git-common-dir 2>/dev/null)
    if [ ! -d "$bare_dir" ]; then
        bare_dir=$(git worktree list --porcelain | grep 'worktree' | head -n1 | cut -d' ' -f2)/.bare
    fi
    echo "$bare_dir"
}

git_get_default_branch() {
    local bare_dir="$1"
    local branch=$(git --git-dir="$bare_dir" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
    echo "$branch"
}

git_get_worktree_path() {
    local bare_dir="$1"
    local branch="$2"
    local path=$(git --git-dir="$bare_dir" worktree list --porcelain | grep -A2 "branch refs/heads/$branch" | grep 'worktree' | cut -d' ' -f2)
    echo "$path"
}

git_wt_pm() {
    local bare_dir
    local branch
    local worktree_path

    bare_dir=$(git_get_bare_dir)
    branch=$(git_get_default_branch "$bare_dir")

    if [ -z "$branch" ]; then
        echo "Error: Could not detect default branch"
        return 1
    fi

    worktree_path=$(git_get_worktree_path "$bare_dir" "$branch")

    if [ -z "$worktree_path" ]; then
        echo "Error: No worktree found for branch '$branch'"
        return 1
    fi

    git --work-tree="$worktree_path" --git-dir="$bare_dir" pull origin "$branch"
}

git_dmb() {
    local default_branch
    default_branch=$(git_get_default_branch)

    if [ -z "$default_branch" ]; then
        echo "Error: Could not detect default branch"
        return 1
    fi

    git branch --merged "origin/$default_branch" \
        | grep -v -e "$default_branch" -e '\*' \
        | xargs git branch -d
    }
