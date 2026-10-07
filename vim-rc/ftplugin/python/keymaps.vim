if exists('b:loaded_python_keymaps_ftplugin')
  finish
endif
let b:loaded_python_keymaps_ftplugin = 1

" Used for test mappings
let maplocalleader = "_"

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

augroup python_grep_keymaps
  autocmd!
  autocmd BufEnter <buffer> call s:SetupGrepKeymaps()
augroup END
