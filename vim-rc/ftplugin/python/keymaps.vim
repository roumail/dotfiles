if exists('b:loaded_python_keymaps_ftplugin')
  finish
endif
let b:loaded_python_keymaps_ftplugin = 1

" Used for test mappings
let maplocalleader = "_"

" pytest.vim and dispatch-extras, in test files only
if expand('%:t') =~# '^test_'
  nmap <buffer> <localleader>rm <Plug>(pytest-run-method)
  nmap <buffer> <localleader>rc <Plug>(pytest-run-class)
  nmap <buffer> <localleader>rf <Plug>(pytest-run-function)
  nmap <buffer> <localleader>rt <Plug>(pytest-run-file)

  " Run with --pdb in terminal
  nmap <buffer> <localleader>dm <Plug>(pytest-pdb-method)
  nmap <buffer> <localleader>dc <Plug>(pytest-pdb-class)
  nmap <buffer> <localleader>df <Plug>(pytest-pdb-function)
  nmap <buffer> <localleader>dt <Plug>(pytest-pdb-file)

  " Run with --trace in terminal
  nmap <buffer> <localleader>tm <Plug>(pytest-trace-method)
  nmap <buffer> <localleader>tc <Plug>(pytest-trace-class)
  nmap <buffer> <localleader>tf <Plug>(pytest-trace-function)
  nmap <buffer> <localleader>tt <Plug>(pytest-trace-file)

  " Yank test paths
  nmap <buffer> <localleader>ym <Plug>(pytest-yank-method)
  nmap <buffer> <localleader>yc <Plug>(pytest-yank-class)
  nmap <buffer> <localleader>yf <Plug>(pytest-yank-function)
  nmap <buffer> <localleader>yF <Plug>(pytest-yank-file)

  " rerun last dispatch command (run) / start command (debug)
  nmap <buffer> <localleader>rd <Plug>(dispatch-extras-repeat-dispatch)
  nmap <buffer> <localleader>rs <Plug>(dispatch-extras-repeat-start)
  " Open log of last dispatch run as a buffer
  nmap <buffer> <localleader>dl <Plug>(dispatch-extras-log)
  " Switch b/w tmux and terminal running strategy for Start (used for debugging)
  nmap <buffer> <localleader>cs <Plug>(dispatch-extras-toggle-start-strategy)
endif

" Scoped grep (fzf-utils-grepscope). The scope is looked up when the key is
" pressed; outside a project these print 'no scope' instead of grepping.
nnoremap <buffer> <leader>rp <Cmd>call fzf_utils#rg_scope#invoke('project python')<CR>
nnoremap <buffer> <leader>rt <Cmd>call fzf_utils#rg_scope#invoke('tests python')<CR>
" Word under the cursor / the selection
nnoremap <buffer> gw <Cmd>call fzf_utils#rg_scope#invoke_word('project python')<CR>
nnoremap <buffer> gW <Cmd>call fzf_utils#rg_scope#invoke_word('tests python')<CR>
xnoremap <buffer> gw <Cmd>call fzf_utils#rg_scope#invoke_word('project python')<CR>
xnoremap <buffer> gW <Cmd>call fzf_utils#rg_scope#invoke_word('tests python')<CR>
