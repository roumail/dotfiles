#!/bin/sh
# For workflow.tape: a new empty directory with bin/ to put first on PATH, and
# prints its path. bin/ has `slides` from the dotfiles, `vim` with only
# quarto-slides and the dotfiles' quarto ftplugin, and an `open` that only
# logs, so the preview's browser doesn't pop up during the recording.
set -e
demo=$(cd "$(dirname "$0")" && pwd)
dotfiles=$(cd "$demo/../../../.." && pwd)
dir=$(mktemp -d)
mkdir "$dir/bin" "$dir/decks"
ln -s "$dotfiles/.config/shell/bin/slides" "$dir/bin/slides"
cat >"$dir/bin/vim" <<VIM
#!/bin/sh
exec $(command -v vim) -u "$demo/vimrc" -i NONE "\$@"
VIM
cat >"$dir/bin/open" <<OPEN
#!/bin/sh
echo "\$@" >>"$dir/open.log"
OPEN
chmod +x "$dir/bin/vim" "$dir/bin/open"
printf '%s\n' "$dir"
