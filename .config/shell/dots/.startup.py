def _main():
    from pathlib import Path
    import sys
    sys.path.append(str(Path.home() / ".pyhacks"))
    try:
        import pyrepl_hacks as repl
    except ImportError:
        pass  # We must be on Python 3.12 or earlier
    else:
        repl.bind("Alt+M", "move-to-indentation")
        repl.bind("Shift+Tab", "dedent")
        repl.bind("Alt+Down", "move-line-down")
        repl.bind("Alt+Up", "move-line-up")
        repl.bind("Shift+Home", "home")
        repl.bind("Shift+End", "end")
        repl.bind("Alt+{", "previous-paragraph")
        repl.bind("Alt+}", "next-paragraph")

        repl.bind_to_insert("Ctrl+N", "[2, 1, 3, 4, 7, 11, 18, 29]")

_main()
del _main  # Don't pollute the global namespace in our REPL
