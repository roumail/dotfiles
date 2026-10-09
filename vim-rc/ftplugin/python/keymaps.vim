if exists('b:loaded_python_keymaps_ftplugin')
  finish
endif
let b:loaded_python_keymaps_ftplugin = 1

" Used for test mappings
let maplocalleader = "_"

" dispatch-extras
" rerun last dispatch command (run) / start command (debug)
nmap <buffer> <localleader>rd <Plug>(dispatch-extras-repeat-dispatch)
nmap <buffer> <localleader>rs <Plug>(dispatch-extras-repeat-start)
" Open log of last dispatch run as a buffer
nmap <buffer> <localleader>dl <Plug>(dispatch-extras-log)
" Switch b/w tmux and terminal running strategy for Start (used for debugging)
nmap <buffer> <localleader>cs <Plug>(dispatch-extras-toggle-start-strategy)
