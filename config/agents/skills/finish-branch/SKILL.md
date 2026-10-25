---
name: finish-branch
description: Wrap up work done on a git branch and hand it back for landing. Use when a task's commits are done, when asked to merge, land or finish a branch, or to get changes onto main.
---

# Finish a branch

The work ends on its branch. Landing it on main, pushing main and opening a
pull request are the user's to do, not the agent's, unless explicitly configured otherwise.

## Steps

1. Check the branch is ready: `git status` is clean and the commits are
   the ones intended (`git log --oneline main..HEAD`).
2. Check it can land without a merge commit:
   ```sh
   git merge-base --is-ancestor main HEAD && echo ff-able
   ```
   If not, say so and offer to rebase it onto main; rebase only if asked.
3. Push the branch only if the user asked for it, and only if the repo's
   `git config --get agents.push` (unset: `branch`) allows it: not when it
   is `none`. Then `git push -u origin <branch>`, never with a pull request.
4. End with the command that lands it, for the user to run:
   ```sh
   git switch main && git merge --ff-only <branch>
   ```
   Say it adds the commits to main with no merge commit, and that pushing
   main is up to them.

## Conventions

- Don't run the merge, even when it is a fast-forward: offer it.
- No attribution trailers in any commit made on the way.
