#!/usr/bin/env bash

# --- Configuration ---
NOTE_DIR=${NOTE_DIR:-$(dirname "${BASH_SOURCE[0]}")}
TRASH_DIR="$NOTE_DIR/trash"
EDITOR=${EDITOR:-vim}
MAX_NOTE_LEN=50
export NOTE_EXT=${NOTE_EXT:-md}

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

rename_note() {
    [ -z "$1" ] && return
    old_name="$1"
    old_file="$old_name.$NOTE_EXT"

    # Read handles the prompt and prefill natively here
    if ! read -e -i "$old_name" -r -p "Rename $old_name -> " new_name; then
        return
    fi

    # Strip trailing whitespace safely without spawning a sed subprocess
    new_name="${new_name%%[[:space:]]}"

    [ -z "$new_name" ] && return
    [ "$new_name" = "$old_name" ] && return

    if [ -e "$new_name.$NOTE_EXT" ]; then
        echo "Target already exists: $new_name.$NOTE_EXT"
        read -r -p "Press Enter to continue..." _
        return
    fi

    mv "$old_file" "$new_name.$NOTE_EXT"
    query="$new_name"
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

        printf "%s\t\033[1m%-50s\033[0m\t\033[0;36m%s\033[0m\n" "$mtime" "$rel_path" "$ftime"
    done | sort -rn | cut -f2- # Sort by epoch, then remove the epoch column
}

copy_note() {
    [ -z "$1" ] && return
    old_file="$1.$NOTE_EXT"

    # Create new filename with -copy suffix
    new_file="$1-copy.$NOTE_EXT"

    # Copy the file
    cp "$old_file" "$new_file"

    # Update markdown file title adding -copy
    IFS= read -r title < "$new_file"
    title=${title#"# "}
    {
        printf '# %s -copy\n' "$title"
        tail -n +2 "$new_file"
    } > "$new_file.tmp" && mv "$new_file.tmp" "$new_file"

    $EDITOR "$new_file"
}

find_in_notes() {
    # We use --field-separator to make parsing with awk bulletproof.
    rg --line-number --no-heading --color=never --with-filename \
        --glob "**/*.$NOTE_EXT" --glob '!trash/*' "." |
    awk -F: -v ext=".$NOTE_EXT" '
    {
        fname=$1;
        line=$2;

        # Keep path, strip extension and leading ./
        sub(ext "$", "", fname)
        sub(/^\.\//, "", fname)

        content = $0
        sub(/^[^:]*:[0-9]+:/, "", content)

        printf "\033[1m%s\033[0m:%03d:%s\n", fname, line, content
    }'
}

# --- FZF Loop ---

key=ctrl-l
query="$*"
opts='--reverse --no-hscroll --no-multi --ansi --print-query --tiebreak=index'
header_actions='ALT-N: new / ALT-C: duplicate / ALT-X: delete / ALT-R: rename'
expect_actions='alt-n,alt-c,alt-x,alt-r'
expect_list="ctrl-f,$expect_actions"
expect_find="ctrl-l,$expect_actions"
header_wrap=$'\n%s\n\n'
header_list=$(printf "$header_wrap" "CTRL-F: find / $header_actions")
header_find=$(printf "$header_wrap" "CTRL-L: list / $header_actions")
list_preview_cmd='bat --color=always --style=grid {1}.$NOTE_EXT 2>/dev/null || cat {1}.$NOTE_EXT'
find_preview_cmd='bat --color=always --style=numbers --highlight-line={2} {1}.$NOTE_EXT 2>/dev/null || cat {1}.$NOTE_EXT'

create_note() {
  local q="$1"
  if [ "${#q}" -gt "$MAX_NOTE_LEN" ]; then
        return 1
    fi
  # Pre-populate with query as title
  # Everything after first / kept - would need to be ${x##*/} to
  # support nested directories
  local title="${q#*/}"
  local file="$q.$NOTE_EXT"
  echo "# $title" > "$file"
  echo "" >> "$file"
  $EDITOR "$file"
}

while true; do
    if [ "$key" = ctrl-l ]; then
        out=$(list_notes | fzf $opts \
            --ghost "Query length limited to ${MAX_NOTE_LEN}" \
            --delimiter=$'\t' \
            --prompt="list> " \
            --expect="$expect_list" --query="$query" \
            --preview "$list_preview_cmd" \
            --header="$header_list")
    else
        out=$(find_in_notes | fzf $opts \
            --prompt="find> " --expect="$expect_find" \
            --delimiter=':' --nth=3.. --query="$query" \
            --preview "$find_preview_cmd" \
            --preview-window 'down,+{2}/2' \
            --header="$header_find")
    fi

    # Exit if fzf was interrupted (ESC / Ctrl-C)
    exit_status=$?
    (( exit_status % 128 == 2 )) && exit 1

    lines=$(wc -l <<< "$out")
    query=$(head -1 <<< "$out")
    # If user pressed Enter with no selection but did type a query,
    # treat it as "create new note" instead of doing nothing / losing intent
    if [ -n "$query" ] && [ "$lines" -lt 2 ]; then
      create_note "$query"
      continue
    fi
    [ "$lines" -lt 2 ] && continue

    newkey=$(head -2 <<< "$out" | tail -1)
    # Extract filename from the last line, trimming trailing whitespace
    selection=$(tail -1 <<< "$out")

    if [ "$key" = ctrl-l ]; then
        file=$(echo "$selection" | awk 'BEGIN { FS="\t" } { print $1 }' | sed 's/[[:space:]]*$//')
    else
        file=$(echo "$selection" | awk -F: '{print $1}' \
            | sed 's/[[:space:]]*$//')
        line_no=$(echo "$selection" | awk -F: '{print $2}' | tr -d ' ')
    fi

    case "$newkey" in
        ctrl-*) key=$newkey ;;
        alt-d)  [ "$lines" -gt 2 ] && delete_note "$file" ;;
        alt-r)  [ "$lines" -gt 2 ] && rename_note "$file" ;;
        alt-c)  [ "$lines" -gt 2 ] && copy_note "$file" ;;
        alt-n)  [ -n "$query" ] && create_note "$query";;
        *)
            if [ "$key" = ctrl-l ]; then
                [ -n "$file" ] && $EDITOR "$file.$NOTE_EXT"
            else
                # Open at specific line
                $EDITOR "$file.$NOTE_EXT" "+$line_no"
            fi
            ;;
    esac
done
