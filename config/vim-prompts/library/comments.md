## Comments

Prefer no comment to an inline comment, and an inline comment to a docstring.
Never add a docstring: a function's name, signature and tests say what it does.
A comment goes only where the rules below say it earns its place; they are the
whole spec, so don't write one for any other reason (a docstring per function,
a header per module, a comment per step). Remove the ones that don't earn it:

- **Point at a document** when reading it is what made the code make sense: a
  spec, an upstream issue, a `:help` topic.
- **Code that can't be understood without its comment** should be changed
  until it can, not explained.
- **Don't describe the implementation.** What the code does and how (the
  steps, the helpers it calls, the data it passes) is in the code; a comment
  repeating it is wrong as soon as the implementation changes. Say why the
  code is this way, what it must guarantee, or nothing.
- **A comment must stay true as the code changes.** If the two could drift
  apart, remove the comment, or move it next to the lines it is about.
- **CLI entry points, examples and docs are exempt**: their comments are
  documentation.
