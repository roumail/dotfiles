## Running tests

What holds wherever tests run. How to run them here (the command, the
virtualenv, the services, local config) is the `test-setup` rule; it is the
source of truth, so don't assume Docker, a virtualenv's location, or which
services are needed.

- Run only the tests that cover the change. Never the full suite unless I ask for it.
- End-to-end tests: before running any, run `git config --get agents.e2e` in the repository (unset means `no`):
  - `no`: never run end-to-end tests; run unit and integration tests only. I run end-to-end tests myself when I want them.
  - `yes`: end-to-end tests may be run, still only when asked.
  Never change `agents.e2e` yourself. If unsure whether a test is end-to-end, treat it as one.
- Services: start only those `test-setup` lists for the task at hand. If one is missing, stop and tell me which, rather than working around it (skipping the test, mocking the service). If `test-setup` is silent, ask rather than guess.
- Local tweaks needed to run (a patch, an environment file): apply them as `test-setup` says, and only if they aren't applied already. They are never committed: don't revert them yourself, leave them out when staging (the git rules). If I keep them in a stash, leave the stash alone.
- Python virtualenv: a repository with one worktree per branch keeps a shared `.venv` in the parent directory, and a worktree may have its own. Before running anything, look for both. If the worktree has its own, ask me which to use, recommending the worktree's; ask once per session. If only one exists, use it; if neither, use the one `test-setup` names. `Sa` (my shell alias) activates `../.venv`, the parent's, whatever the worktree has: for the worktree's own, `source .venv/bin/activate`.
- Don't change test configuration to make a run pass: coverage floors, warnings turned into errors, markers. A persona may lift one for a single run that only measures, and says so.
- Report what you ran (the command), what passed, and for a failure which assertion failed and why, before proposing a change.
