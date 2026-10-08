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

" Scoped grep (grepscope). The scope is looked up when the key is
" pressed; outside a project these print 'no scope' instead of grepping.
nnoremap <buffer> <leader>rp <Cmd>call grepscope#invoke('project python')<CR>
nnoremap <buffer> <leader>rt <Cmd>call grepscope#invoke('tests python')<CR>
" Word under the cursor / the selection
nnoremap <buffer> gw <Cmd>call grepscope#invoke_word('project python')<CR>
nnoremap <buffer> gW <Cmd>call grepscope#invoke_word('tests python')<CR>
xnoremap <buffer> gw <Cmd>call grepscope#invoke_word('project python')<CR>
xnoremap <buffer> gW <Cmd>call grepscope#invoke_word('tests python')<CR>
