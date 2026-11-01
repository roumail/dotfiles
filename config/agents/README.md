# Agents: skills and instructions

Rules and skills for coding agent CLIs (Copilot CLI, Claude Code), set up by
`install.sh`. The rules reach an agent only through vim-prompts' `:Ai`
([Rules](#rules)).

| Path | What it is | Installed as |
| --- | --- | --- |
| `AGENTS.md` | Empty: rules are in `../vim-prompts/` | Written, with `local/AGENTS.md` after it, to `~/.copilot/copilot-instructions.md` and `~/.claude/CLAUDE.md` |
| `skills/<name>/SKILL.md` | Skills, loaded when a task matches their description | Linked into `~/.copilot/skills/` and `~/.claude/skills/` |
| `SKILL.template.md` | Start for a new skill | Not installed |
| `local/AGENTS.md` | Empty, like `AGENTS.md` (gitignored) | Appended to the instructions above |
| `local/skills/` | This machine's own skills (gitignored) | Linked with the shared ones |
| `../vim-prompts/` | The rules, for vim-prompts | Linked into `~/.config/vim-prompts/` |
| `../claude/examples/guard-git.py` | Example hook for Claude Code: blocks pushes `agents.push` doesn't allow, and PRs | Not installed; its docstring says how |

## On a fresh machine

1. Install the tools `install.sh` checks for (fzf uv bat starship wezterm git
   vim curl fd rg delta gh, and brew on macOS), plus Copilot CLI and its
   login (`copilot`, then `/login`).
2. Clone the dotfiles and run the install:
   ```sh
   git clone git@github.com:roumail/dotfiles.git
   cd dotfiles && ./install.sh
   ```
   This links the skills and the rules, and writes the CLIs' (empty)
   instructions. Run again, it updates a local file still unedited from an
   older example. It refuses while the dotfiles have uncommitted changes;
   `./install.sh --dirty` installs them anyway, to try a change out.
3. Name the task rules and the personas in `~/.gitconfig.local`
   ([Rules](#rules)).
4. Choose how far agents may push (see [Push policy](#push-policy)). For a
   machine where they shouldn't push at all:
   ```sh
   git config --file ~/.gitconfig.local agents.push none
   ```
5. Check vim-prompts picked the rules up: `:AiPersonas` in Vim lists them,
   with where each is set.
6. Clear leftovers when you're happy: `trim-dots` lists the files install.sh
   backed up (e.g. a `copilot-instructions.md` you'd written yourself) and
   deletes the ones you pick.

## Push policy

`agents.push` is git config, so it can be set per repo, for the machine, or
not at all:

| Value | Agents may push |
| --- | --- |
| `none` | Nothing, not even a branch |
| `branch` (when unset) | Branches, when asked; never main or master |
| `main` | Anything, when asked |

```sh
git config agents.push main                                 # this repo only (.git/config)
git config --file ~/.gitconfig.local agents.push branch     # this machine's default
```

Use `~/.gitconfig.local`, not `git config --global`: `~/.gitconfig` is the
dotfiles' shared copy (a symlink, which `--global` would also replace with a
plain file). A repo's own setting wins over the machine's.

Opening pull requests is never allowed, whatever the value, and commits carry
no attribution.

**What enforces it.** Nothing: asked through `:Ai`, an agent is told to
check `agents.push` before pushing ([Rules](#rules)); started any other way,
it isn't told. `../claude/examples/guard-git.py` is a Claude Code hook that
blocks what the policy doesn't allow, whatever the agent was told; it isn't
installed. Claude Code's attribution is off in `settings.json` either way.

## Rules

The rules are vim-prompts rules: git config's `vim-prompts.rules` names them,
and [vim-prompts](https://github.com/roumail/vim-prompts) puts them in the
prompt of every `:Ai` ask. The CLIs' own instructions (`AGENTS.md`) are
empty, so a rule is never given twice. The cost: a session started any other
way (`claude`, `copilot`, Copilot in VS Code) gets none of them.

They are kept in `config/vim-prompts/`, which `install.sh` links into
`~/.config/vim-prompts/`. A file at the top goes with every ask; those in
`task-rules/` go when an ask names them (`:Ai #rule:comments ...`), on
machines that name the directory as `vim-prompts.task-rules`:

| File | Rules | Applied by |
| --- | --- | --- |
| `git.md` | Pushing, PRs, attribution, landing a branch | `~/.gitconfig` (the dotfiles'), for every repo |
| `task-rules/comments.md` | When a comment earns its place | `~/.gitconfig.local`, on each machine that wants it; a persona names it (`/draft`, `/review`, `/tests`, `/migrations`) |
| `task-rules/testing.md` | How tests are written, in any language | as above |
| `task-rules/running-tests.md` | The policy for running tests anywhere | as above |
| `task-rules/style.md` | How code is structured; library code versus application code | as above |
| `task-rules/review.md` | What I look for in a review and how I word comments | as above |
| `personas/` | `/draft`, `/review`, `/challenge`, `/tests`, `/migrations` | `~/.gitconfig.local`, as above |
| `stacks/python/` | pytest, the virtualenv, and `/dead-code` and `/schema`; `/draft`, `/review` and `/tests` with them | each Python repo's config ([stacks](../vim-prompts/stacks/README.md)) |
| `local/` | My own setup for a stack (`python-local.md`), unpacked from the stack's example, never committed | the stack's `stack.gitconfig` |

Nothing in `task-rules/` or `personas/` is named in the dotfiles' `.gitconfig`,
so neither follows you to every machine. A machine names them in
`~/.gitconfig.local`:

```sh
git config -f ~/.gitconfig.local --add vim-prompts.task-rules '~/.config/vim-prompts/task-rules'
git config -f ~/.gitconfig.local --add vim-prompts.personas '~/.config/vim-prompts/personas'
```

Name the directory rather than copying its files into another one, so there
is one copy to edit. A team's task rules keep a `comments.md` of their own
only if it is meant to differ from this one.

Only `git.md` goes with every ask: it holds wherever the agent is, whatever
the task. How code is written (`style`, `comments`, `testing`) stays in the
task rules, sent by the personas that write or review code and by `#rule:`, so
a plain `:Ai` question gets none of them and a persona gets each once.

`~/.gitconfig.local` is included last, so its rules come after `git.md`, as
vim-prompts wants the more specific ones. Check what applies in a repo:

```sh
git config --show-origin --get-regexp '^vim-prompts\.'
```

`:AiPersonas` in Vim shows the same. A named file that is missing refuses
every ask, so run `install.sh` before naming it.

## Adding a skill

```sh
mkdir -p config/agents/skills/my-skill        # or local/skills/ for this machine only
cp config/agents/SKILL.template.md config/agents/skills/my-skill/SKILL.md
./install.sh
```

`name` in the frontmatter must match the directory. In Copilot, `/skills
reload` loads a new skill without restarting.
