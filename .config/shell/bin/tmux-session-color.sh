#!/usr/bin/env bash

session_name="$1"

# Exit if no session name was provided
if [ -z "$session_name" ]; then
    exit 1
fi

# Fetch the colors string from the tmux environment
colors_str=$(tmux show -gv @status-colors)

# Read the space-separated string into a standard Bash array
read -ra colors <<< "$colors_str"

# Fallback in case the array is empty
if [ ${#colors[@]} -eq 0 ]; then
    exit 1
fi

# Generate the deterministic hash from the session name
hash_val=$(printf "%s" "$session_name" | cksum | cut -d" " -f1)

# Calculate the index and select the color
col_idx=$(( hash_val % ${#colors[@]} ))
next_color="${colors[$col_idx]}"

# Apply the setting to the specific tmux session
tmux set -t "$session_name" status-left "#[bg=${next_color},fg=black,bold] #S #[default]"
