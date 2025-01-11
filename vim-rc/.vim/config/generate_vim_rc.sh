#!/bin/bash

# Path to your main .vimrc file
MAIN_VIMRC="$HOME/.vimrc"

# Output file
DEBUG_VIMRC="$HOME/.vimrc.debug"

# Function to process a vimrc file
process_vimrc() {
    local file="$1"

    # Check if the file exists
    if [[ ! -f "$file" ]]; then
        echo "\" Warning: File '$file' not found." >> "$DEBUG_VIMRC"
        return
    fi

    echo "\" \n\" ===== Inlining '$file' =====" >> "$DEBUG_VIMRC"

    # Read the file line by line
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip lines that start with "
        if [[ "$line" =~ ^\" ]]; then
            continue
        fi

        # Check if the line is a source command
        if [[ "$line" =~ ^source\ ([^[:space:]]+) ]]; then
            sourced_file="${BASH_REMATCH[1]}"
            # Handle relative paths or tilde expansion
            sourced_file="${sourced_file/#\~/$HOME}"
            # Recursively process the sourced file
            process_vimrc "$sourced_file"
        else
            echo "$line" >> "$DEBUG_VIMRC"
        fi
    done < "$file"

    echo "\" ===== End of '$file' ===== \n" >> "$DEBUG_VIMRC"
}

# Start processing
# Empty the debug vimrc file
> "$DEBUG_VIMRC"

echo "\" ===== Generated Debug VimRC =====" >> "$DEBUG_VIMRC"
echo "\" This file is auto-generated for debugging purposes." >> "$DEBUG_VIMRC"

process_vimrc "$MAIN_VIMRC"

echo "\" ===== End of Generated Debug VimRC =====" >> "$DEBUG_VIMRC"

echo "Debug `.vimrc` has been generated at '$DEBUG_VIMRC'."
