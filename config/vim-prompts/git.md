## Git

- Pushing depends on the repo. Before any push, run
  `git config --get agents.push` in it (unset means `branch`):
  - `none`: never push, not even a branch.
  - `branch`: push branches only when I ask; never main, master or the
    default branch, by any route (`git push` while on it, `origin main`,
    `HEAD:main`, `--all`, force pushes).
  - `main`: pushing main is allowed too, still only when I ask.
  Never change `agents.push` yourself.
- Never open a pull request: no `gh pr create`, no `gh api` calls that create
  one, no links or commands that open one in the browser. A pushed branch is
  as far as you go; whether it becomes a PR is mine to decide.
- No attribution in commits: no `Co-authored-by:` trailers, no "Generated
  with" lines, no mention of an AI or agent in commit messages.
- Getting a branch onto main is my call too: use the finish-branch skill.
- When you commit, stage only the files you changed for the task, by name: never `git add -A`, `git add .` or `git commit -a`. Check `git diff --cached` first, and unstage anything that isn't part of the change, such as local config or test-setup tweaks.
- The use of stashes is permitted as long as other existing stashes aren't dropped.
