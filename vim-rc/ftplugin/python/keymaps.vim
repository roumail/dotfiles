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
