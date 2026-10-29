---
context: ["rule:style", "rule:testing", "rule:running-tests", "rule:test-setup"]
mode: ask
---
{rules}

Find the application code that only tests reach: lines that tests calling it directly cover, and no test that goes through an entrypoint does. This is a report: don't edit any files, except temporary ones you delete before you finish.

{context}

{selection}

1. **Scope.** The package, module or files I name, or the selection's file. The repository's description says what the entrypoints are and which tests drive them (its "Kind and entrypoints" section). If it doesn't say, or the scope is library code, stop and ask.
2. **Which tests.** The tests for the scope, and the scenario tests that reach it (find them by what they import, call or request). If that is most of the suite, tell me how many and ask before running.
3. **Measure.** Run them once with coverage recorded per test, the command and environment as `test-setup` says, with these options instead of any `--no-cov`: `--cov=<package> --cov-context=test --cov-report= --cov-fail-under=0`, then `coverage json --show-contexts -o <a temporary file>`. This run only measures, so the coverage floor is lifted for it; nothing else changes.
4. **Classify** every executable line in the scope, from the contexts (the tests) that covered it: covered by a scenario test, reachable; covered only by other tests, a candidate; covered by none, untested.
5. **Check every candidate by hand** before reporting it: follow its callers up towards an entrypoint (grep the name, registration by name or decorator, `getattr` or string dispatch, signals and hooks, configuration that turns a branch on, including the deployed configuration repositories the description names). Coverage only shows the scenarios don't reach it; say what else could, and if something might, the kind is `ask`.

Answer in this shape, numbering the points once across sections:

## Summary
Two or three sentences: the scope, the tests run (the command), and how much is candidate.

## Only tests reach it
`N. path:start-end [remove|ask]` then, on the next lines: the tests that cover it, why no entrypoint reaches it (the callers you followed), and the tests that would go with it.

## Untested
`N. path:start-end` and one line each: reachable from which entrypoint, if you can tell. These are not for removal; they may be missing scenarios.

## Verdict
The numbers to remove, and the ones I need to decide.

{query}
