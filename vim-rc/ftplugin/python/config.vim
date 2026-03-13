" https://github.com/vim-python/python-syntax?tab=readme-ov-file
let g:python_highlight_all = 1
" vim dispatch
compiler pytest
" https://github.com/tpope/vim-dispatch/issues/315
let b:dispatch = '-compiler=pytest'
" Set default dispach strategy for start to be terminal, not tmux
let g:dispatch_no_tmux_start = 1
