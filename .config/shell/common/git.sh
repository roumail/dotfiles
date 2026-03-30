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
    git --git-dir="$bare_dir" for-each-ref \
      --format='%(worktreepath)' \
      "refs/heads/$branch" | head -n1
}


