---
context: [+style, +comments, +testing, +running-tests, +test-setup?]
mode: agent
---
{rules}

I am giving you a spec; draft an implementation of it in this worktree.

{context}

{selection}

- Work from the spec, and build only what it says. Don't solve for a future scenario that isn't in the spec: no extra options, parameters, generalisations or handling of cases it doesn't mention. When you feel the pull to, don't build it; list it under "Not built" at the end with one line each ("Tempted to make the cutoff configurable; the spec fixes it"), so I'm told and can decide.
- Stop and ask when the spec leaves a decision that changes the design, before writing code or, if it only shows up while building, at that point: what identifies a duplicate, which row is kept, a date or timezone that is ambiguous, where a step belongs, whether something is reversible or touches production data, or two readings that would be built differently. Ask all the questions you have together, each with the options and your recommendation. Don't ask about details you can read from the repository or that the rules decide.
- Anything in the spec that isn't code (merging or cherry-picking a branch, deploys) is mine to do: don't do it, and list it under "For me".
- Write the tests first, and see each fail for the right reason. In application code, start from the entrypoint the spec is about. Then write the code until they pass.
- Follow the rules for every ask, such as a changelog entry where they ask for one.
- End with what you ran and its result, then "Not built" and "For me", leaving out any that are empty. Nothing else: no summary, no review notes, no open questions.
- Leave the changes uncommitted. If I ask you to commit, commit as the git rules say: only the files you wrote for the change, by name, with local test-setup tweaks left out.

{query}
