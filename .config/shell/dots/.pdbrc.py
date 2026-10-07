import inspect
import rich
from rich.console import Console
from pdb import DefaultConfig, Pdb
from pprint import pprint
from functools import lru_cache
import subprocess
import shutil
import os

_console = Console()

# win32yank for wsl
@lru_cache(maxsize=1)
def _clipboard_cmd():
    if shutil.which("pbcopy"):
        return ["pbcopy"]
    if shutil.which("win32yank.exe"):
        return ["win32yank.exe", "-i", "--crlf"]
    raise RuntimeError("No supported clipboard command found (pbcopy/win32yank.exe)")

# https://github.com/python/cpython/blob/3.14/Lib/pdb.py
# expose additional do_ methods that a user can call inside pdb
class Config(DefaultConfig):

    prompt = '(Moo++) '
    sticky_by_default = True
    # The 256 colour formatter prints very dark function names:
    use_terminal256formatter = True
    truncate_long_lines = False

def displayhook(self, obj):
    """If the type defines its own pprint method, use it on its instances."""
    pprint_impl = getattr(obj, 'pprint', None)
    if (
        pprint_impl is not None and
        inspect.ismethod(pprint_impl) and
        pprint_impl.__self__ is not None  # Only call if bound to an object.
    ):
        pprint_impl()
    else:
        try:
            _console.print(obj)
        except Exception:
            print(repr(obj))

Pdb.displayhook = displayhook

def do_findtest(self, arg):
    """ft\n     Find the closest function starting with 'test_', upwards the stack."""
    frames_up = list(reversed(list(enumerate(self.stack[0:self.curindex]))))
    for i, (frame, _) in frames_up:
        if frame.f_code.co_name.startswith('test_'):
            self.curindex = i
            self.curframe = frame
            self.curframe_locals = self.curframe.f_locals
            self.print_stack_entry(self.stack[self.curindex])
            self.lineno = None
            return


def do_bottommost(self, arg):
    """bm\n    Jump to the bottommost frame in the stack."""
    last_frame = self.stack[-1][0]
    last_index = len(self.stack) - 1

    self.curindex = last_index
    self.curframe = last_frame
    self.curframe_locals = self.curframe.f_locals
    self.print_stack_entry(self.stack[self.curindex])
    self.lineno = None
    return

def _copy_text(text):
    data = str(text).replace("\r", "").encode()
    subprocess.run(_clipboard_cmd(), input=data, check=True)

def do_yank(self, arg):
    """yank <expression>\n    Copy str(expression) to clipboard."""
    if not arg.strip():
        self.error("Usage: yank <expression>")
        return
    val = self._getval(arg)
    _copy_text(str(val))

def do_pank(self, arg):
    """pank <expression>\n    Rich-format expression and copy to clipboard."""
    if not arg.strip():
        self.error("Usage: pank <expression>")
        return
    val = self._getval(arg)
    from rich.console import Console
    c = Console(record=True, color_system=None)
    c.print(val)
    _copy_text(c.export_text())

def _current_location(self):
    """(filename, lineno) of the selected frame (follows up/down)."""
    frame, lineno = self.stack[self.curindex]
    return frame.f_code.co_filename, lineno

def do_yline(self, arg):
    """yline [n]
    Copy the current source line (or n lines starting at it), dedented."""
    import linecache
    import textwrap
    try:
        count = int(arg) if arg.strip() else 1
    except ValueError:
        self.error("Usage: yline [n]")
        return
    filename, lineno = _current_location(self)
    lines = [linecache.getline(filename, lineno + i) for i in range(max(count, 1))]
    text = textwrap.dedent("".join(lines)).rstrip("\n")
    if not text:
        self.error(f"No source for {filename}:{lineno}")
        return
    _copy_text(text)
    self.message(text)

def do_yloc(self, arg):
    """yloc
    Copy the current location as path:lineno (relative to cwd when inside it),
    ready for `b path:lineno` or `vim path +lineno`."""
    filename, lineno = _current_location(self)
    rel = os.path.relpath(filename)
    loc = f"{filename if rel.startswith('..') else rel}:{lineno}"
    _copy_text(loc)
    self.message(loc)

def do_ylast(self, arg):
    """ylast [n]
    Copy a command you typed at the prompt: the previous one, or n back.
    Reads the line editor's (up-arrow) history, so it covers pdb commands too."""
    import sys
    try:
        n = int(arg) if arg.strip() else 1
    except ValueError:
        self.error("Usage: ylast [n]")
        return
    rl = self.fancycompleter.config.readline if self.fancycompleter else sys.modules.get("readline")
    if rl is None:
        self.error("No line-editor history available")
        return
    newest_first = [rl.get_history_item(i) for i in range(rl.get_current_history_length(), 0, -1)]
    commands = [x for x in newest_first if x and x.split(" ", 1)[0] != "ylast"]
    if not 1 <= n <= len(commands):
        self.error(f"Only {len(commands)} earlier commands in history")
        return
    _copy_text(commands[n - 1])
    self.message(commands[n - 1])

def do_jsonpank(self, arg):
    """jsonpank <expression>\n    Parse expression as JSON, rich-format it, and copy to clipboard."""
    if not arg.strip():
        self.error("Usage: jsonpank <expression>")
        return
    from rich.console import Console
    import json
    val = self._getval(arg)
    if isinstance(val, str):
        parsed = json.loads(val)
    else:
        parsed = json.loads(str(val))
    c = Console(record=True, color_system=None)
    c.print(parsed)
    _copy_text(c.export_text())

def _normalize(val):
    """Render containers as sorted, indented JSON so line diffs line up.

    Same idea as :NormalizePythonDict / :NormalizeJsonString in vim. Strings that
    parse (JSON, then Python literal) to a dict/list are treated as that container.
    Anything else falls back to str(), i.e. the plain line diff."""
    import ast
    import dataclasses
    import json
    import pprint

    obj = val
    if isinstance(obj, (bytes, bytearray)):
        obj = obj.decode(errors="replace")
    if isinstance(obj, str):
        for parse in (json.loads, ast.literal_eval):
            try:
                obj = parse(obj)
                break
            except Exception:
                pass
    if hasattr(obj, "model_dump"):
        try:
            obj = obj.model_dump(mode="json")
        except Exception:
            pass
    elif dataclasses.is_dataclass(obj) and not isinstance(obj, type):
        obj = dataclasses.asdict(obj)
    if not isinstance(obj, (dict, list, tuple)):
        return str(val)
    try:
        return json.dumps(obj, sort_keys=True, indent=2, ensure_ascii=False, default=repr)
    except (TypeError, ValueError):  # mixed/unsortable keys, circular refs
        return pprint.pformat(obj, sort_dicts=True)

def _parse_two_exprs(self, arg, usage):
    if "--" not in arg:
        self.error(usage)
        return None
    left_expr, right_expr = [x.strip() for x in arg.split("--", 1)]
    if not left_expr or not right_expr:
        self.error(usage)
        return None
    return left_expr, right_expr

def _unified_diff(left, right):
    import difflib
    return "\n".join(
        difflib.unified_diff(
            left.splitlines(),
            right.splitlines(),
            fromfile="expected",
            tofile="actual",
            lineterm="",
        )
    )

def do_pdiff(self, arg):
    """pdiff [-r] [-y] [-u] <expected_expr> -- <actual_expr>
    Side-by-side diff shown through delta (changed words highlighted, styled by
    your gitconfig [delta] section), or plain if delta isn't installed. Dicts/lists
    (or strings holding JSON / Python literals) are normalized to sorted,
    indented JSON first; other values are diffed as str().
    -r  diff str() as-is, no normalization
    -y  also copy the (plain text) diff to the clipboard
    -u  unified (stacked -/+) instead of side by side"""
    usage = "Usage: pdiff [-r] [-y] [-u] <expected_expr> -- <actual_expr>"
    raw = yank = unified = False
    words = arg.split(" ")
    while words and words[0].startswith("-") and words[0] != "--" and set(words[0][1:]) <= {"r", "y", "u"}:
        raw |= "r" in words[0]
        yank |= "y" in words[0]
        unified |= "u" in words[0]
        words.pop(0)
    exprs = _parse_two_exprs(self, " ".join(words), usage)
    if not exprs:
        return
    left_val, right_val = self._getval(exprs[0]), self._getval(exprs[1])
    fmt = str if raw else _normalize
    diff_text = _unified_diff(fmt(left_val), fmt(right_val))
    if diff_text:
        if shutil.which("delta"):
            self.stdout.flush()
            # delta highlights changed *words* (default --word-diff-regex '\w+'), so
            # a 1-char change in a UUID lights up the whole token. For per-character
            # highlights add "--word-diff-regex=." here (not in gitconfig, or git diff
            # changes too).
            delta = ["delta", "--paging=never"] + ([] if unified else ["--side-by-side"])
            subprocess.run(delta, input=diff_text.encode())
        else:
            self.message(diff_text)
        if yank:
            _copy_text(diff_text)
    elif not raw and str(left_val) != str(right_val):
        # JSON collapses 1/"1" and tuple/list; don't let that pass silently
        self.message("(equal after normalization, but str() differs; try pdiff -r)")
    else:
        self.message("(no differences)")

def _open_diff(self, paths):
    """Show paths side by side without blocking pdb, wherever pdb is running."""
    import json
    import shlex
    if os.environ.get("VIM_TERMINAL"):
        # Inside a vim :terminal (chkpyt.sh via Start!): ask the outer vim to call
        # Tapi_PdbDiff (roumail/pytest.vim, plugin/pytest.vim), see :h terminal-api
        self.stdout.write("\x1b]51;" + json.dumps(["call", "Tapi_PdbDiff", paths]) + "\x07")
        self.stdout.flush()
        return True
    vim_cmd = ["vim", "-d", *paths]
    if os.environ.get("TMUX"):
        subprocess.run(["tmux", "new-window", "-n", "pdb-diff", shlex.join(vim_cmd)])
        return True
    wezterm = shutil.which("wezterm") or shutil.which("wezterm.exe")
    if wezterm and (os.environ.get("TERM_PROGRAM") == "WezTerm" or os.environ.get("WEZTERM_PANE")):
        subprocess.run([wezterm, "cli", "spawn", "--", *vim_cmd], stdout=subprocess.DEVNULL)
        return True
    subprocess.run([os.environ.get("EDITOR") or "vim", "-d", *paths])
    return False

def do_vdiff(self, arg):
    """vdiff <expected_expr> -- <actual_expr>
    Normalize both sides like pdiff and diff them (expected left, actual right):
    in a reused vim tab when pdb runs in a vim :terminal, else a tmux window or
    wezterm tab, else a blocking `$EDITOR -d`."""
    exprs = _parse_two_exprs(self, arg, "Usage: vdiff <expected_expr> -- <actual_expr>")
    if not exprs:
        return
    import re
    import tempfile
    tmpdir = tempfile.mkdtemp(prefix="pdb-vdiff-")
    paths = []
    for i, expr in enumerate(exprs, 1):
        name = re.sub(r"[^A-Za-z0-9_.-]+", "_", expr).strip("_")[:60] or "expr"
        path = os.path.join(tmpdir, f"{i}_{name}.json")
        with open(path, "w") as f:
            f.write(_normalize(self._getval(expr)) + "\n")
        paths.append(path)
    # the non-blocking viewers read the files after we return; leave them to the OS
    if not _open_diff(self, paths):
        shutil.rmtree(tmpdir, ignore_errors=True)

def do_dir(self, arg):
    """dir [-p] <expression>
    List attributes of expression, filtering dunders by default.
    With -p, also filter single-underscore (private) attributes."""
    filter_private = False
    if arg.startswith("-p ") or arg == "-p":
        filter_private = True
        arg = arg[3:].strip()
    if not arg:
        self.error("Usage: dir [-p] <expression>")
        return
    val = self._getval(arg)
    if filter_private:
        attrs = [x for x in dir(val) if not x.startswith("_")]
    else:
        attrs = [x for x in dir(val) if not x.startswith("__")]
    rich.print(attrs)

# pdbpp's `display` is per-frame and only prints when the value changes, so it
# goes silent as soon as you step into another function or hit the next
# breakpoint. `watch` is process-wide: every stop prints every watched
# expression evaluated in the current frame.
# Guarded because this file runs again whenever pdbpp builds a fresh Pdb (e.g.
# `debug`); re-capturing preloop then would make _preloop wrap itself.
if not hasattr(Pdb, "_watches"):
    Pdb._watches = {}  # expr -> last repr
    Pdb._orig_preloop = Pdb.preloop

def _show_watches(self):
    from rich.text import Text
    for expr, last in Pdb._watches.items():
        try:
            cur = repr(eval(expr, self.curframe.f_globals, self.curframe_locals))
        except Exception as exc:
            _console.print(Text(f"  {expr}: <{type(exc).__name__}>", style="dim"))
            continue
        changed = last is not None and cur != last
        Pdb._watches[expr] = cur
        line = Text(f"{'*' if changed else ' '} {expr} = ", style="bold yellow" if changed else "bold")
        line.append(cur)
        _console.print(line, overflow="ellipsis", no_wrap=True)

def _preloop(self):
    Pdb._orig_preloop(self)  # sticky redraw + pdbpp display list
    if Pdb._watches:
        _show_watches(self)

def do_watch(self, arg):
    """watch [expression]
    Print expression at every stop, in whatever frame you are in
    (* marks a change). Without an argument, show all watches now."""
    arg = arg.strip()
    if arg:
        Pdb._watches.setdefault(arg, None)
    _show_watches(self)

def do_unwatch(self, arg):
    """unwatch [expression]
    Remove one watch, or all of them without an argument."""
    arg = arg.strip()
    if not arg:
        Pdb._watches.clear()
    elif arg in Pdb._watches:
        del Pdb._watches[arg]
    else:
        self.error(f"{arg} is not watched")

def do_myhelp(self, arg):
    """myhelp
    List the commands added by ~/.pdbrc.py (`help <name>` for the full text)."""
    import re
    from rich.table import Table
    from rich.text import Text
    table = Table(box=None, show_header=False, padding=(0, 2))
    table.add_column(style="bold cyan", no_wrap=True)
    table.add_column()
    for name, fn in _COMMANDS.items():
        usage, *rest = (fn.__doc__ or name).strip().splitlines()
        desc = []
        for line in rest:
            line = line.strip()
            if not line or line.startswith("-"):
                break
            desc.append(line)
        summary = re.split(r"(?<=\.)\s", " ".join(desc), maxsplit=1)[0]
        table.add_row(Text(usage.strip()), Text(summary))  # Text: "[n]" isn't markup
    _console.print(table)

_COMMANDS = {
    "ft": do_findtest,
    "bm": do_bottommost,
    "yank": do_yank,
    "pank": do_pank,
    "jsonpank": do_jsonpank,
    "yline": do_yline,
    "yloc": do_yloc,
    "ylast": do_ylast,
    "pdiff": do_pdiff,
    "vdiff": do_vdiff,
    "dir": do_dir,
    "watch": do_watch,
    "unwatch": do_unwatch,
    "myhelp": do_myhelp,
}

Pdb.preloop = _preloop
for _name, _fn in _COMMANDS.items():
    setattr(Pdb, "do_" + _name, _fn)
