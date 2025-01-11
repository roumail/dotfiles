#!/bin/bash

MAIN_VIMRC="/root/.vimrc"
OUTPUT_FILE="/root/workspace/.vimrc.debug"

> "$OUTPUT_FILE"

echo "\" ===== Generated Debug VimRC =====" >> "$OUTPUT_FILE"
echo "\" This file is auto-generated for debugging purposes." >> "$OUTPUT_FILE"

while IFS= read -r line; do
    if [[ "$line" =~ ^source[[:space:]]+(.+) ]]; then
        # Extract the path from the source command
        sourced_file="${BASH_REMATCH[1]}"
        # Resolve '~' to the home directory
        resolved_path="${sourced_file/#\~/$HOME}"

        # Check if the sourced file exists
        if [[ -f "$resolved_path" ]]; then
            echo "\" ===== Inlining '$resolved_path' =====" >> "$OUTPUT_FILE"
            cat "$resolved_path" >> "$OUTPUT_FILE"
            # Ensure a newline after the sourced file content
            echo "" >> "$OUTPUT_FILE"
            echo "\" ===== End of '$resolved_path' =====" >> "$OUTPUT_FILE"
        else
            echo "\" Warning: Sourced file not found: $resolved_path" >> "$OUTPUT_FILE"
        fi
    # Otherwise, check if the line is a comment or empty
    elif [[ ! "$line" =~ ^[[:space:]]*\" ]] && [[ -n "$line" ]]; then
        echo "$line" >> "$OUTPUT_FILE"
    fi
done < "$MAIN_VIMRC"

echo "\" ===== End of Generated Debug VimRC =====" >> "$OUTPUT_FILE"

echo "Debug .vimrc has been generated at $OUTPUT_FILE"
