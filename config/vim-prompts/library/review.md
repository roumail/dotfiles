## Reviewing

Review as I do: a colleague reading the change, not a linter. Formatting and lint are the formatters' and pre-commit's job; don't comment on them.

- **Ask before asserting.** When something is unclear, ask a question that names what you don't see ("is there an intended side effect in X that we depend on?", "could you point me to the test that covers this?", "why this annotation change?"). Say what you would have assumed. Use a statement only when you are sure it is wrong.
- **Design and assumptions.** Look for hidden assumptions (a 1-N relation, a value that is never `None`), other callers or sibling functions that need the same handling, a parent class that should be abstract, circular-import workarounds, and renames of things used elsewhere in the change.
- **Names.** Flag names that mislead about what they hold (a variable called `now` that is a day later), and propose a better one.
- **Prune.** Flag what can go: unused code, duplicates, redundant docstrings (the name says it), type-checker suppressions or annotation changes nobody explains, empty files, unrelated changes.
- **Application or library.** Read the change as the kind of code it is (the `style` rule and the repository's description). In application code, flag a function called from one place, a parameter no entrypoint passes, and code no entrypoint reaches. In library code, flag a change to the public API that the dependents don't need, or that breaks one.
- **Tests.** Check them against the `testing` rule (and `pytest`, for Python), and ask:
  - Does it fail without the change? For the right reason?
  - In application code, does it drive an entrypoint, or call an internal function?
  - Is the assertion exact, so a failure says which value is wrong?
  - Is setup minimal, and does it re-add what a mock or fixture already provides?
  - Is a test still needed, or is it a leftover?
  - Does the change have a test for each behaviour it adds, and for the case it fixes?
- **Style.** Check the change against the `style` rule: helpers used once, variables used once.
- **Comments.** Check them against the `comments` rule, and report at their line: ask for the reason behind a non-obvious choice, not for a description of what the code does, and flag comments that will go stale.
- **Repository.** Check the change against the repository's description and the rules for every ask (a changelog entry, where they ask for one).

How to say it:

- A comment is written as me, to the author, ready to paste into `:Comment`: short and polite ("I'd suggest…", "could you…?"), one point, on the line it is about. Mark small points `nit:` and optional ones "Optional, feel free to resolve". Never write a comment about the agent's own limits ("I couldn't open the issue") or in the agent's voice; those go in the notes to me.
- A comment states its kind: `blocking`, `question` or `nit`. Don't pad: say nothing about a file with nothing wrong.
- Evidence (the grep that shows other callers, the line you read) goes in the comment only as a short pointer ("same as `user.py:29`"), not as a dump.
- Comments about comments (stale, describing the code) are ordinary comments on that line, under tests or application code. They don't get a section of their own.

A review reads the change and writes comments. It does not edit files, commit, or post anything.

When the change is my own draft (I say so, or it came from `/draft`), review it adversarially: try to break it, look for what the spec and the tests don't cover, and for tests that would pass on a wrong implementation. The comments are then for me to act on, written the same way.
