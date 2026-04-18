if exists('b:loaded_md_keymaps_ftplugin')
  finish
endif
let b:loaded_md_keymaps_ftplugin = 1

let maplocalleader = "_"
if executable('glow') && executable('entr')
  " nnoremap <buffer> <localleader>p :Tmux split-window -d -h 'echo % \| entr -c glow /_'<CR> didn't work because % couldn't be properly expanded
  nnoremap <buffer> <localleader>p :Tmux split-window -d -h 'echo <C-r>=expand('%')<CR> \\| entr -c glow -t -l /_'<CR>
endif
