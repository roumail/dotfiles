#!/bin/bash

# Define the base directory of your vim-rc setup
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
BASE_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"  # Go two levels up to vim-rc/
MAIN_VIMRC="$BASE_DIR/.vimrc"
DEBUG_VIMRC="$BASE_DIR/.vimrc.debug"

# Function to process a vimrc file
process_vimrc() {
    local file="$1"

    # Check if the file exists
    if [[ ! -f "$file" ]]; then
        echo "\" Warning: File '$file' not found." >> "$DEBUG_VIMRC"
        return
    fi

    echo "\" ===== Inlining '$file' =====" >> "$DEBUG_VIMRC"

    # Read the file line by line
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip lines that start with "
        if [[ "$line" =~ ^\" ]]; then
            continue
        fi

        # Check if the line is a source command
        if [[ "$line" =~ ^source\ ([^[:space:]]+) ]]; then
            sourced_file="${BASH_REMATCH[1]}"
            # Recursively process the sourced file
            process_vimrc "$sourced_file"
        else
            # Add the line to the debug file
            echo "$line" >> "$DEBUG_VIMRC"
        fi
    done < "$file"

    echo "\" ===== End of '$file' =====" >> "$DEBUG_VIMRC"
}

# Start processing
> "$DEBUG_VIMRC"  # Truncate the debug vimrc file

echo "\" ===== Generated Debug VimRC =====" >> "$DEBUG_VIMRC"
echo "\" This file is auto-generated for debugging purposes." >> "$DEBUG_VIMRC"

process_vimrc "$MAIN_VIMRC"

echo "\" ===== End of Generated Debug VimRC =====" >> "$DEBUG_VIMRC"

echo "Debug \`.vimrc\` has been generated at '$DEBUG_VIMRC'."
