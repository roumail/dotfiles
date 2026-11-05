## Python virtualenv

- Before running anything, run `ls -d .venv ../.venv 2>/dev/null`. If the checkout has its own `.venv`, use it; otherwise use the parent's `../.venv`. Don't ask.
- Use it by its path, `source <dir>/bin/activate` or `<dir>/bin/python -m pytest`, so the command says which one ran.
