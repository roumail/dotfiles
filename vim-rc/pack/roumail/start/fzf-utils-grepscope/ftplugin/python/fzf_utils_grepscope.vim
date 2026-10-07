if exists('b:loaded_fzf_utils_python_ftplugin')
  finish
endif
let b:loaded_fzf_utils_python_ftplugin = 1

if get(g:, 'fzf_utils_no_mappings', 0)
  finish
endif

" Grep scoped to the project / tests Python files (needs g:project_name)
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
