#!/usr/bin/env bash

# --- Configuration ---
NOTE_DIR=${NOTE_DIR:-$(dirname "${BASH_SOURCE[0]}")}
TRASH_DIR="$NOTE_DIR/trash"
EDITOR=${EDITOR:-vim}
export NOTE_EXT=${NOTE_EXT:-txt}

cd "$NOTE_DIR" || exit 1

# --- OS Detection for 'stat' and 'date' ---
# Linux (GNU) and macOS (BSD) have different flags for file timestamps
if stat --version 2>/dev/null | grep -q GNU; then
    # GNU/Linux logic
    get_mtime() { stat -c "%Y" "$1"; }
    format_date() { date -d "@$1" "+%Y-%m-%d %H:%M"; }
else
    # BSD/macOS logic
    get_mtime() { stat -f "%m" "$1"; }
    format_date() { date -r "$1" "+%Y-%m-%d %H:%M"; }
fi

# --- Core Functions ---

delete_note() {
    echo -en "\r\x1b[KDelete $1? (y/n) "
    read -r yn
    if [[ "$yn" =~ ^y ]]; then
        mkdir -p "$TRASH_DIR"
        mv "$1.$NOTE_EXT" "$TRASH_DIR/"
    fi
}

list_notes() {
    # Use fd to find files, then a loop to get timestamps and format
    fd -e "$NOTE_EXT" --exclude "trash" -0 | while read -d $'\0' file; do
        mtime=$(get_mtime "$file")
        ftime=$(format_date "$mtime")
        # fname=$(basename "$file" ".$NOTE_EXT")
        # Remove the file extension but KEEP the directory path (e.g., "attachments/my-file")
        rel_path="${file%.$NOTE_EXT}"
        # Remove leading "./" if present
        rel_path="${rel_path#./}"

        # Output: relative_path [TAB] formatted_date
        # We display the relative path in fzf so you know where it lives
        printf "%s\t\033[1m%-50s\033[0m\t\033[0;36m%s\033[0m\n" "$mtime" "$rel_path" "$ftime"
        # # Output: epoch_time [TAB] formatted_name [TAB] formatted_date
        # printf "%s\t\033[1m%-50s\033[0m\t\033[0;36m%s\033[0m\n" "$mtime" "$fname" "$ftime"
    done | sort -rn | cut -f2- # Sort by epoch, then remove the epoch column
}

find_in_notes() {
    # We use --field-separator to make parsing with awk bulletproof.
    rg --line-number --no-heading --color=always --with-filename --glob '!trash/*' "." |
    awk -F: -v ext=".$NOTE_EXT" '
    {
        fname=$1;
        line=$2;
        col=$3;
        content=$4;

        # Keep path, strip extension and leading ./
        fname=file_with_ext;
        sub(ext, "", fname);
        sub(/^\.\//, "", fname);

        prefix=sprintf("\033[1m%s\033[0m:%03d:", fname, line);
        printf "%s %s\n", prefix, content}'
}

# --- FZF Loop ---

key=ctrl-l
query="$*"
opts='--reverse --no-hscroll --no-multi --ansi --print-query --tiebreak=index'

while true; do
    if [ "$key" = ctrl-l ]; then
        out=$(list_notes | fzf $opts  --delimiter=$'\t' --prompt="list> " --expect=ctrl-f,alt-d,alt-n --query="$query" \
            --preview "bat --color=always --style=grid {1}.$NOTE_EXT 2>/dev/null || cat {1}.$NOTE_EXT" \
            --header=$'\nCTRL-F: find / ALT-N: new / ALT-D: delete\n\n')
    else
        out=$(find_in_notes | fzf $opts --prompt="find> " --expect=ctrl-l,alt-d,alt-n \
            --delimiter=':' --nth=3.. --query="$query" \
            --preview "bat --color=always --style=numbers --highlight-line={2} {1}.$NOTE_EXT 2>/dev/null || cat {1}.$NOTE_EXT" \
            --preview-window 'down,+{2}/2' \
            --no-clear --header=$'\nCTRL-L: list / ALT-N: new / ALT-D: delete\n\n')
    fi

    # Exit if fzf was interrupted (ESC / Ctrl-C)
    exit_status=$?
    (( exit_status % 128 == 2 )) && exit 1

    lines=$(wc -l <<< "$out")
    [ "$lines" -lt 2 ] && continue

    query=$(head -1 <<< "$out")
    newkey=$(head -2 <<< "$out" | tail -1)
    # Extract filename from the last line, trimming trailing whitespace
    selection=$(tail -1 <<< "$out")

    if [ "$key" = ctrl-l ]; then
        file=$(echo "$selection" | awk 'BEGIN { FS="\t" } { print $1 }' | sed 's/[[:space:]]*$//')
    else
        file=$(echo "$selection" | awk -F: '{print $1}' | sed 's/[[:space:]]*$//')
        line_no=$(echo "$selection" | awk -F: '{print $2}' | tr -d ' ')
    fi

    case "$newkey" in
        ctrl-*) key=$newkey ;;
        alt-d)  [ "$lines" -gt 2 ] && delete_note "$file" ;;
        alt-n)  [ -n "$query" ] && $EDITOR "$query.$NOTE_EXT" ;;
        *)
            if [ "$key" = ctrl-l ]; then
                [ -n "$file" ] && $EDITOR "$file.$NOTE_EXT"
            else
                # Open at specific line (works for Vim, Nano, VS Code)
                $EDITOR "$file.$NOTE_EXT" "+$line_no"
            fi
            ;;
    esac
done
