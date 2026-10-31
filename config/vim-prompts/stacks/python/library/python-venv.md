## Python virtualenv

- A repository with one worktree per branch keeps a shared `.venv` in the parent directory (`../.venv`), and a worktree may have its own (`.venv`). Before running anything, look for both. If the worktree has its own, ask me which to use, recommending the worktree's; ask once per session. If only one exists, use it; if neither, use the one `test-setup` names.
- Use it by its path, `source <dir>/bin/activate` or `<dir>/bin/python -m pytest`, so the command says which one ran.
