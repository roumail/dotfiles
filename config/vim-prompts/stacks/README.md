# Stacks

What briefs an ask comes in layers, each more specific than the one before,
in the order git config reads them:

| Layer | Where | What goes in it | Turned on |
| --- | --- | --- | --- |
| base | `../task-rules/`, `../personas/` | How I work in any language: testing, style, review, comments | every repo (`~/.gitconfig.local`) |
| stack | `stacks/<stack>/` | One ecosystem's way of doing what base says: its test framework, its environment, personas only it can run | per repo or group, by including `stack.gitconfig` |
| local | `../local/`, never committed | My own setup for a stack: shell aliases, paths on this machine | with the stack: its `stack.gitconfig` names `local/` too |
| repo | the repo's config | What this repo is, and how to run its tests here | that repo |

Base and stacks are opinionated but never personal: someone else could take
them as they are. Anything that only makes sense on my machine goes in
`local`, as everywhere in these dotfiles (`~/.gitconfig.local`,
`.config/shell/local/`); not git's `local` scope.

## Vocabulary

- **Stack rules are named `<stack>-<topic>`** (`python-pytest`,
  `python-venv`), so two stacks never hide each other's rules and
  `+<stack>-<Tab>` lists one stack's.
- **A stack extends a base persona** with a persona of the same name whose
  template is `{base}`, adding its rules to `context` (`personas/draft.md`).
  A persona only one stack can run (`dead-code`, `schema`) lives in that
  stack whole.
- **Hooks** are rules a layer asks for but never ships. A persona marks each
  with `?` (`+test-setup?`), so where no task-rules directory has it, it is
  left out and costs nothing; any other rule that is missing refuses the ask:

  | Hook | Supplied by | For |
  | --- | --- | --- |
  | `test-setup` | the repo | the command, services and local tweaks to run its tests |
  | `<stack>-local` | local | my own setup for that stack, sent only where the stack is on |

  Every persona of a stack takes `+<stack>-local?`.
- **Replace** a rule or persona by giving a later layer a file of the same
  name: a repo's `python-pytest.md` replaces the stack's in that repo only.
  **Add to** a rule only through a hook; rules have no `{base}`.

## Unpacking a stack

A stack is one folder; everything it needs outside the repo comes from an
example in it. `install.sh` links the folder into `~/.config/vim-prompts/`
and copies each `stacks/<stack>/*.example` into `local/` without the
`.example` (`python-local.md.example` → `local/python-local.md`), unless that
file is there already. Edit the copy: `local/` is ignored, so it stays on
this machine. A copy left as the example says nothing worth following, and
an empty one is not sent.

## Turning a stack on

One include per repo, in its own config:

```sh
git config --local --add include.path ~/.config/vim-prompts/stacks/python/stack.gitconfig
```

For every repo below a folder, include it from `~/.gitconfig.local` instead:

```sh
git config -f ~/.gitconfig.local \
  'includeIf.gitdir:~/projects/acme/.path' ~/.config/vim-prompts/stacks/python/stack.gitconfig
```

`git config --show-origin --get-regexp '^vim-prompts\.'` and `:AiPersonas`
show which stack each value comes from.

## Adding a stack

`stacks/<stack>/` with:

- `stack.gitconfig`, naming its `task-rules/`, its `personas/` and `local/`;
- `task-rules/`, rules named `<stack>-<topic>`;
- `personas/`, extending base ones with `{base}`, each taking `+<stack>-local?`;
- `<stack>-local.md.example`, the start of the hook's local copy.

Run `install.sh` to unpack it.
