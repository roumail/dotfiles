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

def do_diffyank(self, arg):
    """diffyank [-r] <expected_expr> -- <actual_expr>
    Print a unified diff and copy it to the clipboard. Dicts/lists (or strings
    holding JSON / Python literals) are normalized to sorted, indented JSON first;
    other values are diffed as str(). With -r, always diff str() as-is."""
    raw = False
    if arg == "-r" or arg.startswith("-r "):
        raw = True
        arg = arg[2:].strip()
    exprs = _parse_two_exprs(self, arg, "Usage: diffyank [-r] <expected_expr> -- <actual_expr>")
    if not exprs:
        return
    left_val, right_val = self._getval(exprs[0]), self._getval(exprs[1])
    fmt = str if raw else _normalize
    left, right = fmt(left_val), fmt(right_val)

    import difflib
    diff_text = "\n".join(
        difflib.unified_diff(
            left.splitlines(),
            right.splitlines(),
            fromfile="expected",
            tofile="actual",
            lineterm="",
        )
    )
    if diff_text:
        self.message(diff_text)
        _copy_text(diff_text)
    elif not raw and str(left_val) != str(right_val):
        # JSON collapses 1/"1" and tuple/list; don't let that pass silently
        self.message("(equal after normalization, but str() differs; try diffyank -r)")
    else:
        self.message("(no differences)")

def do_vdiff(self, arg):
    """vdiff <expected_expr> -- <actual_expr>
    Normalize both sides like diffyank and open them in `$EDITOR -d`
    (expected left, actual right).
    Quit vim to return to pdb."""
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
    editor = os.environ.get("EDITOR") or "vim"
    subprocess.run([editor, "-d", *paths])
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

Pdb.preloop = _preloop
Pdb.do_ft = do_findtest
Pdb.do_bm = do_bottommost
Pdb.do_yank = do_yank
Pdb.do_pank = do_pank
Pdb.do_jsonpank = do_jsonpank
Pdb.do_yline = do_yline
Pdb.do_yloc = do_yloc
Pdb.do_diffyank = do_diffyank
Pdb.do_vdiff = do_vdiff
Pdb.do_dir = do_dir
Pdb.do_watch = do_watch
Pdb.do_unwatch = do_unwatch
