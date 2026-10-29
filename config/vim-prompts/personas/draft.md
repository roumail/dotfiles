---
context: ["rule:style", "rule:comments", "rule:testing", "rule:pytest", "rule:running-tests", "rule:test-setup"]
mode: agent
---
{rules}

I am giving you a spec; draft an implementation of it in this worktree.

{context}

{selection}

- Work from the spec, and build only what it says. Don't solve for a future scenario that isn't in the spec: no extra options, parameters, generalisations or handling of cases it doesn't mention. When you feel the pull to, don't build it; list it under "Not built" at the end with one line each ("Tempted to make the cutoff configurable; the spec fixes it"), so I'm told and can decide.
- Stop and ask, before writing code, when the spec leaves a decision that changes the design: what identifies a duplicate, which row is kept, a date or timezone that is ambiguous, where a step belongs, whether something is reversible or touches production data, or two readings that would be built differently. Ask once, all the questions together, each with the options and your recommendation. Don't ask about details you can read from the repository or that the rules decide.
- Anything in the spec that isn't code (merging or cherry-picking a branch, deploys) is mine to do: don't do it, and list it under "For me".
- Read the repository's description and conventions in the rules above, and follow them. Its description says whether this is application or library code, and what the entrypoints are.
- Write the tests first, as the `testing` rule describes, and see each fail for the right reason, except where another rule, such as `migrations`, says not to write tests. In application code, start from the entrypoint the spec is about, and write the scenario through it. Then write the code until they pass.
- Run the tests as the `running-tests` and `test-setup` rules say, starting with its question about which virtualenv to use.
- Write code as the `style` rule says for this kind of code, and comments only as the `comments` rule allows.
- Follow the rules for every ask, such as a changelog entry where they ask for one.
- Finish by saying what I should attack when I review this myself with `/review` (the weakest assumptions, and what the tests don't cover).
- Leave the changes uncommitted. If I ask you to commit, commit as the git rules say: only the files you wrote for the change, by name, with local test-setup tweaks left out.

{query}
