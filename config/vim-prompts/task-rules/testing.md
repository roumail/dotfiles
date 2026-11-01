## Writing tests

How tests are written, in any language. How they are run is the
`running-tests` rule and this repository's `test-setup`.

- **Application code is tested by scenarios through an entrypoint.** A test sets up the state the scenario starts from, drives one entrypoint the way its user would (a request through the test client, a CLI command, a worker run with its configuration, a task), and asserts on what that user or the next system sees: the response, the rows written, the messages sent, the files produced. Don't test an internal function directly: if a branch can't be reached through an entrypoint, it goes (the `style` rule). The repository's description lists its entrypoints.
- **Library code is tested through its public API**, one behaviour per test.
- **Mock only at the boundary** the code doesn't own: the network, another service, the clock. Never mock the code under test or its internals.
- Keep setup minimal so the test reads like an experiment: only what this test changes is visible. Helpers carry the shared setup.
- Prefer a new case of an existing test to a new test, when the setup and the assertions are the same. When they differ significantly, write a separate test.
- Expose the literal values a case uses (strings, names, expected ids), not callables or computed values.
- Assert the exact outcome: the full error message, the explicit names and ids, and no unexpected logs or warnings. Don't assert on a symptom of the bug (a warning, say) that contradicts the desired behaviour.
- A change has a test for each behaviour it adds, and for the case it fixes, unless a rule for the task says it gets none (a migration, verified against the database instead): that rule wins over this one and over any "tests first" instruction.
- Verify a test fails for the right reason before trusting it: run it against the code without the change, and check the failure is the one you expect.
- While a bug is known but not fixed, write the test for the desired behaviour and mark it as an expected failure that must fail (strict), with one shared marker so the marks are easy to find. The commit that fixes the bug removes the mark.
- Tests, scripts or files written only to explore or check something are temporary: delete them before you finish, unless I asked to keep them. The tests that belong to the change stay.
