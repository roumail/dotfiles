# roumail Vim package

Four small plugins under `start/`, loaded automatically by Vim (`:h packages`).
Each one is grouped by what it is for and installs on its own; none requires
another from this package.

```
junegunn/fzf.vim
├── fzf-utils        find files: :FzfToggleIgnored, previewed :Files / :Buffers,
│                    fd as the fzf file source                        (needs fd)
└── fzf-utils-rg     search contents: :Grep (live), :Rg (static), replay,
                     :GrepScope with its registry of project strategies (needs rg)

tpope/vim-dispatch
├── dispatch-extras  repeat last :Start, Start strategy toggle, open log
└── pytest           run / debug / yank pytest targets            (needs chkpyt.sh)
```

The two fzf plugins share one setting, `g:fzf_include_ignored`: fzf-utils-rg
reads it on every search, and `:FzfToggleIgnored` (fzf-utils) flips it. pytest
adds the dispatch-extras mappings listed below only when dispatch-extras is
installed.

## fzf-utils

- `:FzfToggleIgnored` flips `g:fzf_include_ignored` (default `0`: skip ignored files)
  and fires `User FzfUtilsIgnoredToggled`.
- `:Files[!]`, `:Buffers[!]`: fzf.vim's commands with a preview window.
- Sets `$FZF_DEFAULT_COMMAND` to an `fd` command unless it is already set, and
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

### :GrepScope

`:GrepScope [pattern]` shows a menu of scopes, then runs `:Grep` in the one you
pick. `all` is always offered; the rest comes from the detected project. With no
project it falls back to `:Grep`.

The plugin ships no idea of what a project is. You register strategies, and at
startup the first one whose `detect()` returns a name becomes the project:

```vim
call fzf_utils#project#register('python', {
      \ 'detect': function('s:pyproject_name'),
      \ 'scopes': function('s:python_scopes'),
      \ })
```

- `detect()` returns the project name, or `''` when this is not such a project.
- `scopes(name)` returns the menu entries in order, as `[label, rg-args]` pairs,
  e.g. `[['src', ['src/']], ['src go', ['src/', '-tgo']]]`. Arguments ending in
  `/` are search paths, anything else is passed to ripgrep.

Strategies are tried in registration order. The detected name is kept in
`g:project_name`; set that yourself beforehand to override the name only.
`fzf_utils#rg_scope#invoke(label [, pattern])` greps a scope without the menu,
for mappings. The pyproject.toml strategy and the Python-buffer mappings built
on it live in the dotfiles config (`custom/plugins/fzf/grepscope.vim`,
`ftplugin/python/keymaps.vim`), not in the plugin.

| Keys | Mode | Action |
| --- | --- | --- |
| `<leader>rs` | n | `:GrepScope` |
| `<leader>rw` | n, x | `:GrepScope` for the word under the cursor / selection |

`let g:fzf_utils_no_mappings = 1` skips the mappings of the whole fzf-utils family.

## dispatch-extras

Binds no keys itself; it provides `<Plug>` mappings for pytest or your vimrc.

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
| `<localleader>rd`, `<localleader>rs` | With dispatch-extras: repeat the last `:Dispatch` / `:Start` |
| `<localleader>dl`, `<localleader>cs` | With dispatch-extras: open the last log / toggle the `:Start` strategy |

`let g:pytest_no_mappings = 1` skips them.
