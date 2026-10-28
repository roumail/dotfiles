---
name: finish-branch
description: Wrap up work already committed on a git branch other than main, then land it or hand it back for landing. Use when asked to merge, land or finish such a branch. Not a reason to create a branch: in repos where commits go straight to main, there is nothing to finish.
---

# Finish a branch

- The work ends on its branch unless the user asks to land it.
- Landing it on main happens only when the user asks.
- Pushing main happens only when the user asks and the repo's `agents.push`
  is `main`.
- Opening a pull request is always the user's.

## Steps

1. Check the branch is ready: `git status` is clean and the commits are
   the ones intended (`git log --oneline main..HEAD`).
2. Choose how to land it, following the user's instruction or else the
   repo's habit (`git log --oneline --graph -20 main`: merge commits or a
   straight line). Ask when neither settles it.
   - Fast-forward: possible as is when
     `git merge-base --is-ancestor main HEAD` succeeds; otherwise rebase the
     branch onto main first.
   - Merge commit: `git merge --no-ff <branch>` keeps the branch visible in
     history.
3. Push the branch itself only if the user asked to. Check
   `git config --get agents.push` first (unset means `branch`): `none` means
   no push at all; `branch` or `main` allow `git push -u origin <branch>`.
   Never open a pull request.
4. Land it with `git switch main`, then the merge chosen in step 2
   (`git merge --ff-only <branch>` for a fast-forward).
   - If `agents.push` is `main` and the user asked to land or push main,
     run it, then `git push origin main`.
   - Otherwise stop before landing and give the user the commands to run,
     saying pushing main is up to them.

## Conventions

- No attribution trailers in any commit made on the way.
