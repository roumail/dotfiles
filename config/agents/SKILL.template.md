---
# Agent Skills format (agentskills.io), read by Claude Code and Copilot CLI.
# Copy to config/agents/skills/<name>/SKILL.md; `name` must match <name>.
name: skill-name
# What it does AND when to use it: the agent loads the body only when this
# matches the task, so name the triggers (file types, verbs, tools). <=1024 chars.
description: Does X for Y. Use when the user asks to ..., or when working with ...
# Optional; both tools honour it. Omit to inherit the session's permissions.
# allowed-tools: Bash(git:*), Read
---

# Skill name

One or two sentences on the goal of this skill.

## When to use

- Situation that should trigger this skill
- Situation that should NOT (point to the better tool or skill)

## Steps

1. First thing to do
2. Next thing, with the exact command:
   ```sh
   command --flag
   ```
3. How to verify it worked

## Conventions

- Rules the agent would otherwise get wrong

## Resources

Files next to this SKILL.md, loaded only when needed (paths relative to it):

- `scripts/example.sh`: run, don't read
- `references/details.md`: read when ...
