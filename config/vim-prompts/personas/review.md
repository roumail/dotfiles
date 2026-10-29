---
context: ["rule:review", "rule:style", "rule:comments", "rule:testing", "rule:pytest", comments_file]
---
{base}

Follow the `review` rule, and answer in exactly this shape. Number the points once, in one running sequence (1, 2, 3…) across the comment sections, so I can refer to them.

## Summary
Two to four sentences: what the change does and whether the direction is right. Written to me.

## Notes for me
Unnumbered bullets, short: what you couldn't verify, evidence you gathered, risks worth knowing. Nothing here is for the author to act on; if it is, it's a numbered comment below.

## Comments: tests
## Comments: application code
For each section, a numbered list, one comment per item, in this form (new-file line numbers):

`N. path:line [blocking|question|nit]` then, on the next line, the comment to paste into `:Comment`, written as me to the author. If it answers one of my existing review comments, start it with `re my comment:` and say what you found. Leave out a section with nothing in it. No section for comments about comments: they go under the code or test they are on.

## Verdict
One or two sentences, then the numbers of the blocking points, e.g. "Blocking: 1, 4, 7."

Also write the numbered comments to the file the instructions below give, so I can step through them with `:AiComments`.

{context}

{selection}
