if exists('b:loaded_python_keymaps_ftplugin')
  finish
endif
let b:loaded_python_keymaps_ftplugin = 1

function! s:SetupPytestKeymaps() abort
  if expand('%:t') !~ '^test_'
    return
  endif

  " Open log of last dispatch run as a buffer
  nnoremap <buffer> <localleader>dl :tabedit `=dispatch#request().file`<CR>
  " Switch b/w tmux and terminal running strategy for Start (used for debugging)
  nnoremap <buffer> <localleader>cs :call pytest#dispatch#toggle_strategy()<CR>
  nnoremap <buffer> <localleader>rm :RunPytestScope method<CR>
  nnoremap <buffer> <localleader>rc :RunPytestScope class<CR>
  nnoremap <buffer> <localleader>rf :RunPytestScope function<CR>
  nnoremap <buffer> <localleader>rt :RunPytestScope file<CR>

  " Run with --pdb in terminal
  nnoremap <buffer> <localleader>dm :RunPytestScopeTrace! method<CR>
  nnoremap <buffer> <localleader>dc :RunPytestScopeTrace! class<CR>
  nnoremap <buffer> <localleader>df :RunPytestScopeTrace! function<CR>
  nnoremap <buffer> <localleader>dt :RunPytestScopeTrace! file<CR>

  " Run with --trace in terminal
  nnoremap <buffer> <localleader>tm :RunPytestScopeTrace method<CR>
  nnoremap <buffer> <localleader>tc :RunPytestScopeTrace class<CR>
  nnoremap <buffer> <localleader>tf :RunPytestScopeTrace function<CR>
  nnoremap <buffer> <localleader>tt :RunPytestScopeTrace file<CR>

  " rerun last start command (debug)
  nnoremap <buffer> <localleader>rs :call pytest#dispatch#RepeatLast()<CR>
  " https://github.com/tpope/vim-dispatch/issues/80#issuecomment-290958499
  nnoremap <buffer> <localleader>rd :Copen \| Dispatch<CR>

  " Yank test paths
  nnoremap <buffer> <localleader>ym :YankTestMethod<CR>
  nnoremap <buffer> <localleader>yc :YankTestClass<CR>
  nnoremap <buffer> <localleader>yf :YankTestFunction<CR>
  nnoremap <buffer> <localleader>yF :YankTestFile<CR>
endfunction

let maplocalleader = "_"

function! s:SetupGrepKeymaps() abort
  if !exists('g:project_name')
    return
  endif

  nnoremap <buffer> <leader>rr <Cmd>call fzf_utils#live_grep#replay()<CR>
  nnoremap <buffer> <leader>rp <Cmd>call fzf_utils#rg_scope#invoke('project python')<CR>
  nnoremap <buffer> <leader>rt <Cmd>call fzf_utils#rg_scope#invoke('tests python')<CR>
endfunction

augroup python_grep_keymaps
  autocmd!
  autocmd BufEnter <buffer> call s:SetupGrepKeymaps()
augroup END

augroup python_pytest_keymaps
  autocmd!
  autocmd BufEnter <buffer> call s:SetupPytestKeymaps()
augroup END
