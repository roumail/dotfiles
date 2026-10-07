# roumail Vim package

Six small plugins under `start/`, loaded automatically by Vim (`:h packages`).
Two families; an indented plugin needs the one above it installed.

```
junegunn/fzf.vim
├── fzf-utils               :FzfToggleIgnored (rg + fd), previewed :Files / :Buffers
├── fzf-utils-fd            fd as the fzf file source                    (needs fd)
└── fzf-utils-rg            :Grep (live), :Rg (static), replay           (needs rg)
    └── fzf-utils-grepscope   :GrepScope, project detection

tpope/vim-dispatch
└── dispatch-extras         repeat last :Start, Start strategy toggle, open log
    └── pytest              run / debug / yank pytest targets            (needs chkpyt.sh)
```

The fd and rg plugins work without fzf-utils (they read `g:fzf_include_ignored`
directly); it only adds the command that flips it.

## fzf-utils

- `:FzfToggleIgnored` flips `g:fzf_include_ignored` (default `0`: skip ignored files)
  and fires `User FzfUtilsIgnoredToggled`.
- `:Files[!]`, `:Buffers[!]`: fzf.vim's commands with a preview window.

## fzf-utils-fd

Sets `$FZF_DEFAULT_COMMAND` to an `fd` command unless it is already set, and
rebuilds it when the ignore toggle flips.

## fzf-utils-rg

| Command | What it does |
| --- | --- |
| `:Grep[!] [pattern] [-- rg-options/paths]` | Live grep: ripgrep re-runs as you type. `C-r` regex, `C-f` fixed string, `C-w` word. |
| `:Rg[!] <rg args>` | Static grep: ripgrep runs once, fzf filters the result. |

| Keys | Action |
| --- | --- |
| `<leader>r/` | `:Grep` |
| `<leader>r.` | `:Grep` in the current buffer's directory |
| `<leader>r:` | Prefill `:Grep` on the command line |
| `<leader>rr` | Replay the last live grep with its last query |

## fzf-utils-grepscope

`:GrepScope [pattern]` picks a scope (all / project / tests, optionally Python
only), then runs `:Grep` in it. It needs `g:project_name`, read at startup from
the `name` in the nearest `pyproject.toml`; set it yourself (e.g. in
`.vim.custom`) to override.

| Keys | Mode | Action |
| --- | --- | --- |
| `<leader>rs` | n | `:GrepScope` |
| `<leader>rw` | n, x | `:GrepScope` for the word under the cursor / selection |
| `<leader>rp`, `<leader>rt` | n | Python buffers: grep project / tests Python files |
| `gw`, `gW` | n, x | Python buffers: word or selection in project / tests Python files |

`let g:fzf_utils_no_mappings = 1` skips the mappings of the whole fzf-utils family.

## dispatch-extras

Binds no keys itself; it provides `<Plug>` mappings for companions or your vimrc.

| Mapping | Action |
| --- | --- |
| `<Plug>(dispatch-extras-repeat-start)` | Repeat the last `:Start` |
| `<Plug>(dispatch-extras-repeat-dispatch)` | `:Copen` and repeat the last `:Dispatch` |
| `<Plug>(dispatch-extras-toggle-start-strategy)` | Toggle `:Start` between terminal and tmux |
| `<Plug>(dispatch-extras-log)` | Open the log of the last dispatch run |

## pytest

Python buffers get `compiler pytest` and `b:dispatch`, so a plain `:Dispatch`
runs pytest too.

| Command (Python buffers) | What it does |
| --- | --- |
| `:RunPytest[!] [args]` | `:Dispatch` pytest with the given arguments. |
| `:RunPytestScope[!] {method\|class\|function\|file}` | Run the test around the cursor. |
| `:RunPytestScopeTrace[!] {scope}` | Same, in a terminal with `--trace` (`!`: `--pdb`). |
| `:TracePytest [args]` | Run in a terminal with `--trace`. |
| `:YankTestMethod`, `:YankTestClass`, `:YankTestFunction`, `:YankTestFile` | Copy the pytest node id. |

`:ParsePytestFailures` (any buffer) reduces pasted pytest output to one line per
test. `Tapi_PdbDiff` is the terminal-API hook that pdb's `vdiff` (`.pdbrc.py`)
calls to show expected | actual in a diff tab.

| Keys (`test_*.py` buffers) | Action |
| --- | --- |
| `<localleader>r` + `m` `c` `f` `t` | Run method / class / function / file |
| `<localleader>t` + `m` `c` `f` `t` | Same with `--trace` |
| `<localleader>d` + `m` `c` `f` `t` | Same with `--pdb` |
| `<localleader>y` + `m` `c` `f` `F` | Yank method / class / function / file node id |
| `<localleader>rd`, `<localleader>rs` | dispatch-extras: repeat the last `:Dispatch` / `:Start` |
| `<localleader>dl`, `<localleader>cs` | dispatch-extras: open the last log / toggle the `:Start` strategy |

`let g:pytest_no_mappings = 1` skips them.
