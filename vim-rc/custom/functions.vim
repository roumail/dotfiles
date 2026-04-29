function! SmartFilterClose()
  let l:current = bufnr('%')
  " Define what to ignore
  let l:skip_bt = ['terminal', 'nofile']
  let l:skip_ft = ['netrw']

  " Get all listed buffers
  let l:all_bufs = filter(range(1, bufnr('$')), 'buflisted(v:val)')

  " Filter out based on our skip variables
  let l:valid_bufs = filter(l:all_bufs,
        \ 'index(l:skip_bt, getbufvar(v:val, "&buftype")) == -1 && ' .
        \ 'index(l:skip_ft, getbufvar(v:val, "&filetype")) == -1')

  " Find index and jump.
  " If current is a terminal, idx is -1, so it jumps to the last valid buffer.
  let l:idx = index(l:valid_bufs, l:current)
  let l:target_idx = (l:idx - 1 + len(l:valid_bufs)) % len(l:valid_bufs)

  execute 'buffer ' . l:valid_bufs[l:target_idx]

  " Delete with silent! to ignore Netrw/Terminal complaints
  execute 'silent! bdelete! ' . l:current
endfunction

function! s:Scratch(bang)
  if a:bang
    split
  else
    vsplit
  endif
  noswapfile hide enew
  setlocal buftype=nofile bufhidden=wipe
  let l:idx = 1
  while bufexists('scratch' . l:idx)
    let l:idx += 1
  endwhile
  execute 'file scratch' . l:idx
endfunction

command! -bang Scratch call s:Scratch(<bang>0)

function! s:ScratchFrom(cmd)
  enew
  setlocal buftype=nofile bufhidden=wipe noswapfile
  call setline(1, systemlist(a:cmd))
endfunction

command! -nargs=+ ScratchFrom call s:ScratchFrom(<q-args>)


" The default lsp behaviour is to open a quickfix/location list
"https://github.com/prabirshrestha/vim-lsp/pull/1140/changes#diff-5644b29c0f34f56ca832ab251585503f273b59b2149cf29c7a38c004c2bad69c
" These overrides attempt to prevent these from happening
function! MyLspQuickfix() abort
  " botright copen
endfunction

function! ToggleQuickfix()
  " Check if any quickfix window is open
  let l:win = filter(range(1, winnr('$')), 'getwinvar(v:val, "&buftype") ==# "quickfix"')
  if empty(l:win)
    copen
  else
    cclose
  endif
endfunction

function! MyLspLocationlist() abort
  " botright lopen
endfunction

let g:Lsp_copen_funcref = function('MyLspQuickfix')
let g:Lsp_lopen_funcref = function('MyLspLocationlist')

function! DetectProjectName() abort
  " guard
  if exists('g:project_name')
    return
  endif

  let l:file = findfile('pyproject.toml', '.;')
  if empty(l:file) || !filereadable(l:file)
    return
  endif

  try
    for l:line in readfile(l:file)
      if l:line =~ '^name\s*='
        let g:project_name = matchstr(l:line, '"\zs[^"]\+\ze"')
        break
      endif
    endfor
  catch
    return
  endtry
endfunction

command! QuickFixToLocList call setloclist(0, getqflist())
command! LocListToQuickFix call setqflist(getloclist(0))
