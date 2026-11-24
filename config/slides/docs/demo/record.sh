#!/bin/sh
# Records the README's GIFs into docs/. Needs quarto, Chrome and ffmpeg for
# deck.gif; vhs, tmux and quarto-slides (~/.vim/plugged/quarto-slides, or
# $DEMO_QUARTO_SLIDES) for workflow.gif.
#
#   docs/demo/record.sh               both
#   docs/demo/record.sh workflow      one
set -e
cd "$(dirname "$0")"
[ $# -eq 0 ] && set -- deck workflow
for name do
  case $name in
    deck) ./deck.sh ;;
    workflow) vhs workflow.tape ;;
    *) echo "record.sh: no such GIF: $name" >&2; exit 2 ;;
  esac
done
