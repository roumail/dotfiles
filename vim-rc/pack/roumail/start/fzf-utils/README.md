# fzf-utils

Live grep, scoped grep and an ignore toggle on top of [fzf.vim](https://github.com/junegunn/fzf.vim).

Requires `junegunn/fzf`, `junegunn/fzf.vim`, `rg` and `fd`.

## Commands

| Command | What it does |
| --- | --- |
| `:Grep[!] [pattern] [-- rg-options/paths]` | Live grep: ripgrep re-runs as you type. `C-r` regex, `C-f` fixed string, `C-w` word. |
| `:GrepScope [pattern]` | Pick a scope (all / project / tests, optionally Python only), then `:Grep` in it. |
| `:Rg[!] <rg args>` | Static grep: ripgrep runs once, fzf filters the result. |
| `:Files[!]`, `:Buffers[!]` | fzf.vim's commands with a preview window. |
| `:FzfToggleIgnored` | Include or skip ignored files, for both `rg` and `fd`. |

`:GrepScope` needs `g:project_name`. It is read at startup from the `name` in the
nearest `pyproject.toml`; set it yourself (e.g. in `.vim.custom`) to override.

## Mappings

| Keys | Mode | Action |
| --- | --- | --- |
| `<leader>r/` | n | `:Grep` |
| `<leader>r.` | n | `:Grep` in the current buffer's directory |
| `<leader>r:` | n | Prefill `:Grep` on the command line |
| `<leader>rr` | n | Replay the last live grep with its last query |
| `<leader>rs` | n | `:GrepScope` |
| `<leader>rw` | n, x | `:GrepScope` for the word under the cursor / selection |
| `<leader>rp`, `<leader>rt` | n | Python buffers: grep project / tests Python files |
| `gw`, `gW` | n, x | Python buffers: word or selection in project / tests Python files |

Set `let g:fzf_utils_no_mappings = 1` to skip all of them.

## Options

- `g:fzf_include_ignored` (default `0`): start with ignored files included.
- `$FZF_DEFAULT_COMMAND`: left alone if already set, otherwise set to an `fd` command.
