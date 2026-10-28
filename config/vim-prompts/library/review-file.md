## Review comments as a file for Vim

Besides your answer, write your numbered comments to a file that vim-review
loads into Vim's quickfix list, so I can step through them on their lines
(`:CommentsLoad`, then `:cnext`).

- Where: the directory `"$(git rev-parse --git-common-dir)/vim-review/$(git branch --show-current)"`, run from the repository's root (on a detached HEAD, `git rev-parse --short=7 HEAD` in place of the branch). Create it if it's missing. The file is `<YYYYmmdd-HHMMSS>-agent.txt` there, the time being now, so it's the newest and `:CommentsLoad` with no file loads it.
- One entry per comment: `path:line: text`, or `path:start-end: text` for a range. `path` is relative to the repository's root, and the lines are as they are in the working tree now, the ones you read.
- `text` is the comment's number and kind as in your answer, then the comment as written to paste: `3. [blocking] could you check the None case here?`. A comment of several lines goes on in the lines after it, each starting with a tab.
- Nothing else in the file: no headings, no notes, no blank lines. Comments that aren't on a line (the summary, the notes for me) stay in the answer only.
- Write it once your answer is final, overwriting nothing: a new file each time. End the answer with its path.
