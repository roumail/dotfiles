## Comments

Write a comment only where it earns its place, and remove the ones that don't:

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
