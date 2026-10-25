#!/usr/bin/env python3
"""PreToolUse hook for Bash: holds git pushes to each repo's agents.push and
blocks opening PRs anywhere.

agents.push is git config, so per clone (.git/config) with a default in
~/.gitconfig: `none` (no pushes), `branch` (the default: branches, not
main/master) or `main` (anything). It reads the whole command, so it also
catches `cd repo && git push` and a bare `git push` while on main. Exit 2
blocks the call and shows stderr to Claude. A directory it can't read, such
as `git -C $DIR`, gets the default policy.

An example, not installed. To use it, copy it to ~/.claude/hooks/ and add to
~/.claude/settings.json (https://docs.claude.com/en/docs/claude-code/hooks):

  "hooks": {"PreToolUse": [{"matcher": "Bash", "hooks": [{"type": "command",
    "command": "python3 \"$HOME/.claude/hooks/guard-git.py\""}]}]}
"""
import json
import os
import re
import shlex
import subprocess
import sys

PROTECTED = {"main", "master"}


def block(reason):
    print(f"Blocked by guard-git: {reason}. See the git rules (~/.config/vim-prompts/git.md); "
          "the user can change it with `git config agents.push`.", file=sys.stderr)
    sys.exit(2)


def git(cwd, *args):
    try:
        out = subprocess.run(["git", "-C", cwd, *args],
                             capture_output=True, text=True, timeout=5)
        return out.stdout.strip()
    except (OSError, subprocess.SubprocessError):
        return ""


def push_policy(cwd):
    policy = git(cwd, "config", "--get", "agents.push") or "branch"
    return policy if policy in ("none", "branch", "main") else "branch"


def ref_name(refspec):
    """The destination branch of a refspec: main for main, HEAD:main, +x:refs/heads/main"""
    dst = refspec.lstrip("+").split(":")[-1]
    return re.sub(r"^refs/heads/", "", dst)


def check_push(args, cwd):
    """args: what follows `git push`"""
    policy = push_policy(cwd)
    if policy == "main":
        return
    if policy == "none":
        block("this repo's agents.push is none: no pushes")
    positional = [a for a in args if not a.startswith("-")]
    refspecs = positional[1:]  # the first is the remote
    if any(ref_name(r) in PROTECTED for r in refspecs):
        block("pushing to main/master")
    if "--all" in args or "--mirror" in args:
        block("pushing every branch, main included")
    if not refspecs and git(cwd, "branch", "--show-current") in PROTECTED:
        block("`git push` while on main/master")


def check(segment, cwd):
    """One simple command; returns the directory the next one runs in"""
    try:
        words = shlex.split(segment)
    except ValueError:
        words = segment.split()
    # Leading VAR=value assignments
    while words and re.match(r"^\w+=", words[0]):
        words = words[1:]
    if not words:
        return cwd
    if words[0] == "cd" and len(words) > 1:
        return os.path.join(cwd, os.path.expanduser(words[1]))
    if words[0] == "git":
        rest = words[1:]
        # git -C dir / -c key=value before the subcommand
        while len(rest) > 1 and rest[0] in ("-C", "-c"):
            if rest[0] == "-C":
                cwd = os.path.join(cwd, os.path.expanduser(rest[1]))
            rest = rest[2:]
        if rest and rest[0] == "push":
            check_push(rest[1:], cwd)
    if words[0] == "gh" and words[1:3] == ["pr", "create"]:
        block("opening a pull request")
    # gh api POSTs when given fields or input; a GET (listing PRs) is fine
    if words[0] == "gh" and len(words) > 1 and words[1] == "api" \
            and any(re.search(r"/pulls/?$", w) for w in words) \
            and any(w in ("-f", "-F", "--field", "--raw-field", "--input", "POST")
                    or w.startswith(("--method=POST", "-XPOST")) for w in words):
        block("opening a pull request through gh api")
    return cwd


def main():
    data = json.load(sys.stdin)
    command = data.get("tool_input", {}).get("command", "")
    cwd = data.get("cwd") or os.getcwd()
    for segment in re.split(r"&&|\|\||;|\||\n", command):
        cwd = check(segment.strip(), cwd)


if __name__ == "__main__":
    main()
