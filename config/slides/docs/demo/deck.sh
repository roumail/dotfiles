#!/bin/sh
# Records docs/deck.gif: deck.qmd rendered, then each slide and each step
# (fragment) captured with headless Chrome. Needs quarto, Chrome and ffmpeg.
set -e
cd "$(dirname "$0")"
chrome=${DEMO_CHROME:-"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

cp deck.qmd "$work/deck.qmd"
cp ../../custom.scss "$work/custom.scss"
quarto render "$work/deck.qmd" --quiet
html="file://$work/deck.html"

# <slide id>:<number of steps>:<seconds on the last step>; reveal only takes a
# step in the URL after an id (#/<id>/<step>), not after an index
frames="title-slide:0:2.5 slide:0:3 incremental:3:2.5 pause:1:2.5 columns:0:3 code:1:2.5 notes:0:3.5 background:0:2"

n=0
shot() { # <url hash> <seconds>
  n=$((n + 1))
  png=$(printf '%s/%03d.png' "$work" "$n")
  "$chrome" --headless=new --disable-gpu --hide-scrollbars --window-size=960,540 \
    --virtual-time-budget=3000 --screenshot="$png" "$html#/$1" >/dev/null 2>&1
  printf "file '%s'\nduration %s\n" "$png" "$2" >>"$work/list.txt"
}
for f in $frames; do
  IFS=: read -r slide steps hold <<EOF
$f
EOF
  shot "$slide" "$([ "$steps" -eq 0 ] && echo "$hold" || echo 1.2)"
  i=0
  while [ "$i" -lt "$steps" ]; do
    shot "$slide/$i" "$([ "$i" -eq $((steps - 1)) ] && echo "$hold" || echo 1.2)"
    i=$((i + 1))
  done
done
# The concat demuxer drops the last duration unless the file is listed again
tail -2 "$work/list.txt" | head -1 >>"$work/list.txt"

ffmpeg -loglevel error -y -f concat -safe 0 -i "$work/list.txt" \
  -vf "fps=10,scale=800:-1:flags=lanczos,split[a][b];[a]palettegen=stats_mode=diff[p];[b][p]paletteuse=dither=none" \
  ../deck.gif
echo "Wrote docs/deck.gif"
