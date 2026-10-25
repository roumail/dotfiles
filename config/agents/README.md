# Agents: skills and instructions

Shared rules and skills for coding agent CLIs (Copilot CLI, Claude Code), set
up by `install.sh`.

| Path | What it is | Installed as |
| --- | --- | --- |
| `AGENTS.md` | Rules every session follows (git: pushing, PRs, attribution) | Written, with `local/AGENTS.md` after it, to `~/.copilot/copilot-instructions.md` and `~/.claude/CLAUDE.md` |
| `skills/<name>/SKILL.md` | Skills, loaded when a task matches their description | Linked into `~/.copilot/skills/` and `~/.claude/skills/` |
| `SKILL.template.md` | Start for a new skill | Not installed |
| `local/AGENTS.md` | This machine's extra rules (gitignored) | Appended to the instructions above |
| `local/skills/` | This machine's own skills (gitignored) | Linked with the shared ones |
| `../claude/hooks/guard-git.py` | Claude Code only: blocks pushes `agents.push` doesn't allow, and PRs | Linked into `~/.claude/hooks/` |

The instructions files are generated: edit `AGENTS.md` or `local/AGENTS.md`,
then run `install.sh` again. Don't edit the copies in your home directory.

## On a fresh machine

1. Install the tools `install.sh` checks for (fzf uv bat starship wezterm git
   vim curl fd rg delta gh, and brew on macOS), plus Copilot CLI and its
   login (`copilot`, then `/login`).
2. Clone the dotfiles and run the install:
   ```sh
   git clone git@github.com:roumail/dotfiles.git
   cd dotfiles && ./install.sh
   ```
   This creates `config/agents/local/AGENTS.md` from the example, writes
   `~/.copilot/copilot-instructions.md`, and links the skills.
3. Add this machine's restrictions to `config/agents/local/AGENTS.md` (e.g.
   no installing packages, no sending code to web services), then run
   `./install.sh` again.
4. Choose how far agents may push (see [Push policy](#push-policy)). For a
   machine where they shouldn't push at all:
   ```sh
   git config --file ~/.gitconfig.local agents.push none
   ```
5. Check Copilot picked everything up. Start `copilot` in any repo, then:
   - `/instructions` lists `~/.copilot/copilot-instructions.md`.
   - `/skills list` lists `finish-branch`. If it doesn't,
     `/skills info finish-branch` says why; skills are symlinks, so check the
     link in `~/.copilot/skills/finish-branch/` resolves.
   - Ask "what are your rules for git pushes?". It should describe
     `agents.push`.

   Copilot reads instructions when a session starts. After changing them,
   start a new session (`/new`), or exit and run `copilot --continue`.
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

**What enforces it.** On Copilot the rules are instructions only: Copilot is
told to check `agents.push` before pushing, but nothing stops a push it
decides to make. Claude Code also runs `guard-git.py` before every shell
command, which blocks what the policy doesn't allow.

## vim-prompts rules

[vim-prompts](https://github.com/roumail/vim-prompts) adds rules to every
`:Ai` ask from git config's `vim-prompts.rules`. The rules are kept here, in
`config/vim-prompts/`, and `install.sh` links them into
`~/.config/vim-prompts/`:

| File | What it is |
| --- | --- |
| `comments.md` | When a comment earns its place |
| `vim-plugins.gitconfig` | Sets `vim-prompts.rules` to `comments.md` |

Where the repos it applies to live differs per machine, so the `includeIf`
that applies it goes in `~/.gitconfig.local`:

```sh
git config -f ~/.gitconfig.local \
  'includeIf.gitdir:~/home/2_AREAS/work/vim-plugins/.path' \
  '~/.config/vim-prompts/vim-plugins.gitconfig'
```

The trailing `/` takes in every repo below the folder, worktrees included.
Check it in one of them, and outside, where nothing should be listed:

```sh
git config --show-origin --get-regexp '^vim-prompts\.'
```

`:AiPersonas` in Vim shows the same. A named file that is missing refuses
every ask, so run `install.sh` before adding the `includeIf`.

## Adding a skill

```sh
mkdir -p config/agents/skills/my-skill        # or local/skills/ for this machine only
cp config/agents/SKILL.template.md config/agents/skills/my-skill/SKILL.md
./install.sh
```

`name` in the frontmatter must match the directory. In Copilot, `/skills
reload` loads a new skill without restarting.
