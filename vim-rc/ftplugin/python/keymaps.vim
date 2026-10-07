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

function! s:SetupGrepKeymaps() abort
  if !exists('g:project_name')
    return
  endif

  nnoremap <buffer> <leader>rp <Cmd>call fzf_utils#rg_scope#invoke('project python')<CR>
  nnoremap <buffer> <leader>rt <Cmd>call fzf_utils#rg_scope#invoke('tests python')<CR>
  nnoremap <buffer> gw <Cmd>call fzf_utils#rg_scope#invoke(
        \ 'project python',
        \ '\b' . expand('<cword>') . '\b'
        \ )<CR>
  nnoremap <buffer> gW <Cmd>call fzf_utils#rg_scope#invoke(
        \ 'tests python',
        \ '\b' . expand('<cword>') . '\b'
        \ )<CR>
  xnoremap <silent> <buffer> gw y<Cmd>call fzf_utils#rg_scope#invoke(
        \ 'project python',
        \ '\b' . escape(getreg('"'), '\') . '\b'
        \ )<CR>
  xnoremap <silent> <buffer> gW y<Cmd>call fzf_utils#rg_scope#invoke(
        \ 'tests python',
        \ '\b' . escape(getreg('"'), '\') . '\b'
        \ )<CR>
endfunction

" g:project_name comes from project-detect, which runs at VimEnter: after the
" ftplugin of any file opened on the command line. Buffers loaded later map
" straight away; the earlier ones wait for User ProjectDetected.
function! s:OnProjectDetected() abort
  for l:buf in getbufinfo({'bufloaded': 1})
    if getbufvar(l:buf.bufnr, '&filetype') !=# 'python'
      continue
    endif
    if l:buf.bufnr == bufnr('%')
      call s:SetupGrepKeymaps()
    else
      " Buffer-local mappings can only be made in the current buffer
      execute 'autocmd python_grep_keymaps BufEnter <buffer=' . l:buf.bufnr
            \ . '> ++once call s:SetupGrepKeymaps()'
    endif
  endfor
endfunction

if exists('g:project_name')
  call s:SetupGrepKeymaps()
elseif !exists('#python_grep_keymaps#User#ProjectDetected')
  " Defined once: clearing the group would drop other buffers' hooks
  augroup python_grep_keymaps
    autocmd User ProjectDetected call s:OnProjectDetected()
  augroup END
endif
