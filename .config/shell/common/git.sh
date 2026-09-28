# Git worktree helper functions
git_get_bare_dir() {
    local bare_dir=$(git rev-parse --git-common-dir 2>/dev/null)
    if [ ! -d "$bare_dir" ]; then
        bare_dir=$(git worktree list --porcelain | grep 'worktree' | head -n1 | cut -d' ' -f2)/.bare
    fi
    echo "$bare_dir"
}

# Default branch (main/master). Optional arg: git dir (e.g. the bare repo).
# Prefers origin/HEAD, since in a non-bare repo HEAD is just the current branch.
git_get_default_branch() {
    local g=(git)
    [ -n "${1:-}" ] && g+=(--git-dir="$1")
    local branch=""

    branch=$("${g[@]}" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@^origin/@@')

    if [ -z "$branch" ]; then
        for candidate in main master; do
            if "${g[@]}" show-ref --verify --quiet "refs/remotes/origin/$candidate" || \
               "${g[@]}" show-ref --verify --quiet "refs/heads/$candidate"; then
                branch="$candidate"
                break
            fi
        done
    fi

    # Last fallback: HEAD, but only in a bare repo where it isn't a checkout.
    if [ -z "$branch" ] && [ "$("${g[@]}" rev-parse --is-bare-repository 2>/dev/null)" = "true" ]; then
        branch=$("${g[@]}" symbolic-ref --short HEAD 2>/dev/null)
    fi

    echo "$branch"
}


git_get_worktree_path() {
    local bare_dir="$1"
    local branch="$2"
    git --git-dir="$bare_dir" for-each-ref \
      --format='%(worktreepath)' \
      "refs/heads/$branch" | head -n1
}
