import inspect
from pdb import DefaultConfig, Pdb
from pprint import pprint
from functools import lru_cache
import subprocess
import shutil

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
        # Use rich for pretty printing instead of pprint
        from rich.console import Console
        Console().print(obj)
        # pprint(obj)

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

def _char_diff(left, right):
    import difflib
    from rich.text import Text

    matcher = difflib.SequenceMatcher(None, left, right)
    rich_text = Text()
    plain_parts = []

    for tag, i1, i2, j1, j2 in matcher.get_opcodes():
        if tag == "equal":
            rich_text.append(left[i1:i2])
            plain_parts.append(left[i1:i2])
        elif tag == "delete":
            rich_text.append(left[i1:i2], style="red strike")
            plain_parts.append(f"[-{left[i1:i2]}-]")
        elif tag == "insert":
            rich_text.append(right[j1:j2], style="green")
            plain_parts.append(f"{{+{right[j1:j2]}+}}")
        elif tag == "replace":
            rich_text.append(left[i1:i2], style="red strike")
            rich_text.append(right[j1:j2], style="green")
            plain_parts.append(f"[-{left[i1:i2]}-]{{+{right[j1:j2]}+}}")

    return rich_text, "".join(plain_parts)

def do_diffyank(self, arg):
    """diffyank [-c] <left_expr> -- <right_expr>
    Diff two expressions and copy result to clipboard.
    Default is a unified line diff. With -c, diff char-wise instead."""
    charwise = False
    if arg == "-c" or arg.startswith("-c "):
        charwise = True
        arg = arg[2:].strip()

    if "--" not in arg:
        self.error("Usage: diffyank [-c] <left_expr> -- <right_expr>")
        return
    left_expr, right_expr = [x.strip() for x in arg.split("--", 1)]
    if not left_expr or not right_expr:
        self.error("Usage: diffyank [-c] <left_expr> -- <right_expr>")
        return

    left = str(self._getval(left_expr))
    right = str(self._getval(right_expr))

    if charwise:
        rich_text, plain_text = _char_diff(left, right)
        from rich.console import Console
        Console().print(rich_text)
        _copy_text(plain_text)
        return

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
    self.message(diff_text)
    _copy_text(diff_text)

def do_dir(self, arg):
    """dir [-p] <expression>
    List attributes of expression, filtering dunders by default.
    With -p, also filter single-underscore (private) attributes."""
    import rich
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

Pdb.do_ft = do_findtest
Pdb.do_bm = do_bottommost
Pdb.do_ft = do_findtest
Pdb.do_bm = do_bottommost
Pdb.do_yank = do_yank
Pdb.do_pank = do_pank
Pdb.do_jsonpank = do_jsonpank
Pdb.do_diffyank = do_diffyank
Pdb.do_dir = do_dir