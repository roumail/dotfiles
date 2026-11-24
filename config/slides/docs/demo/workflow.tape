Output ../workflow.gif
Set Shell "bash"
Set FontSize 15
Set Width 1180
Set Height 520
Set Padding 8
Set TypingSpeed 70ms
Set Framerate 12
Set Theme "Builtin Dark"

Hide
Type `export DEMO="$(./setup.sh)" PS1='$ ' && export PATH="$DEMO/bin:$PATH" SLIDES_TEMPLATE_DIR="$PWD/../.." && cd "$DEMO/decks" && tmux -L slides-demo -f /dev/null new-session -e PATH="$PATH" -e SLIDES_TEMPLATE_DIR="$SLIDES_TEMPLATE_DIR" -e PS1="$PS1" 'tmux set status off; exec bash --norc'` Enter
Sleep 1500ms
Type "clear" Enter
Sleep 500ms
Show

Type "slides new 2026-12-lorem" Sleep 500ms Enter
Sleep 2s
Type "cd 2026-12-lorem && slides edit" Sleep 500ms Enter
Sleep 2s
# _p: quarto preview in a pane on the right; the browser opens on the deck
Type "_p"
Sleep 7s
# Each :w re-renders and reloads the browser
Type "o" Enter Type "- Dolor sit amet" Escape
Sleep 500ms
Type ":w" Sleep 300ms Enter
Sleep 4s
# _r: the self-contained slides.html, to present, mail or attach
Type "_r"
Sleep 8s

Hide
Type ":qa!" Enter
Sleep 500ms
Type "tmux -L slides-demo kill-server" Enter
