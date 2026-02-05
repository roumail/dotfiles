#!/bin/bash
# ~/.tmux-paste.sh
win32yank.exe -o --lf | sed 's/\r$//' | tmux load-buffer -
tmux paste-buffer
