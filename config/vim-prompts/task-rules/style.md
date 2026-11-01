## Style

The repository's description says whether its code is application code or
library code, or which packages are which. Where it doesn't say, ask before
applying a rule below that differs between the two.

Everywhere:

- **Extract only duplication.** Write a function when the same code appears in more than one place, and not otherwise.
- **Inline single-use variables.** A variable assigned and used once is replaced by its value where it is needed. Keep a variable only when it is used more than once.
- Build only what is asked: no option, parameter or branch for a case nobody has today.

**Application code** (run, not imported: an app, workers, a CLI, scheduled tasks):

- Its entrypoints are its only interface: the routes and views, CLI commands, workers and tasks the description lists. Everything else exists to serve one of them.
- A function called from one place is inlined there, whatever its size, unless a framework calls it by name (a route handler, a task, a hook). A function tests patch is no exception: patch at the boundary it calls (the HTTP client, the clock) instead.
- Code no entrypoint can reach is removed, even when a test covers it, and the tests that reached it go with it. A test that calls an internal function shows nothing about the application.
- No parameter, option or branch that no entrypoint uses.

**Library code** (imported by other code):

- Its public API is what its dependents import, and that is its interface: public functions stay functions, and are tested directly.
- Behind the API, the application rules apply: a private helper used once is inlined.
- Before calling public code unused, search the dependents the description names.
