" dispatch-extras: small helpers on top of tpope/vim-dispatch. No keys are
" bound here; pytest or your vimrc map the <Plug>s.
if exists('g:loaded_dispatch_extras')
  finish
endif
let g:loaded_dispatch_extras = 1

" Open log of last dispatch run as a buffer
nnoremap <Plug>(dispatch-extras-log) :tabedit `=dispatch#request().file`<CR>
" Switch b/w tmux and terminal running strategy for Start (used for debugging)
nnoremap <Plug>(dispatch-extras-toggle-start-strategy) <Cmd>call dispatch_extras#toggle_start_strategy()<CR>
" rerun last start command (debug)
nnoremap <Plug>(dispatch-extras-repeat-start) <Cmd>call dispatch_extras#repeat_last_start()<CR>
" rerun last dispatch command (run)
" https://github.com/tpope/vim-dispatch/issues/80#issuecomment-290958499
nnoremap <Plug>(dispatch-extras-repeat-dispatch) :Copen \| Dispatch<CR>
