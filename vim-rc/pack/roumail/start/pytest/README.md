# pytest

Run, debug and yank pytest targets from Python buffers, through
[vim-dispatch](https://github.com/tpope/vim-dispatch).

Requires `tpope/vim-dispatch` and `chkpyt.sh` (`.config/shell/bin`) on `$PATH`.

Python buffers get `compiler pytest` and `b:dispatch`, so a plain `:Dispatch`
runs pytest too.

## Commands (Python buffers)

| Command | What it does |
| --- | --- |
| `:RunPytest[!] [args]` | `:Dispatch` pytest with the given arguments. |
| `:RunPytestScope[!] {method\|class\|function\|file}` | Run the test around the cursor. |
| `:RunPytestScopeTrace[!] {scope}` | Same, in a terminal with `--trace` (`!`: `--pdb`). |
| `:TracePytest [args]` | Run in a terminal with `--trace`. |
| `:YankTestMethod`, `:YankTestClass`, `:YankTestFunction`, `:YankTestFile` | Copy the pytest node id. |

`:ParsePytestFailures` (any buffer) reduces pasted pytest output to one line per test.

`Tapi_PdbDiff` is the terminal-API hook that pdb's `vdiff` (`.pdbrc.py`) calls to
show expected | actual in a diff tab.

## Mappings (`test_*.py` buffers)

| Keys | Action |
| --- | --- |
| `<localleader>r` + `m` `c` `f` `t` | Run method / class / function / file |
| `<localleader>t` + `m` `c` `f` `t` | Same with `--trace` |
| `<localleader>d` + `m` `c` `f` `t` | Same with `--pdb` |
| `<localleader>y` + `m` `c` `f` `F` | Yank method / class / function / file node id |
| `<localleader>rd`, `<localleader>rs` | Repeat the last `:Dispatch` / `:Start` |
| `<localleader>dl` | Open the log of the last dispatch run |
| `<localleader>cs` | Toggle `:Start` between terminal and tmux |

Set `let g:pytest_no_mappings = 1` to skip all of them.
