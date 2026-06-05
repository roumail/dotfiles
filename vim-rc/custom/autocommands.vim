" Set @/ register for vim search integration
function! s:fzf_query_to_search() abort
  let pattern = fzf#vim#get_event().query

  call setreg('/', pattern)
  call histadd('/', pattern)
endfunction

autocmd User FzfQuery call s:fzf_query_to_search()

" Understand jsconc
autocmd FileType json syntax match Comment +\/\/.\+$+

augroup remember_window_view
  autocmd!
  autocmd BufWinLeave * if &buftype == '' | let b:winview = winsaveview() | endif
  autocmd BufWinEnter * if &buftype == '' && exists('b:winview') | call winrestview(b:winview) | endif
augroup END

" Remember cursor position when reopening a file
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost,BufWinEnter *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \ exe "normal! g`\"" |
        \ endif
augroup END

function! s:WithPreservedCursor(Callback) abort
  if &readonly || !&modifiable
    return
  endif

  let save_cursor = getpos('.')
  try
    call call(a:Callback, [])
  finally
    call setpos('.', save_cursor)
  endtry
endfunction

function! s:StripTrailingWhitespace() abort
  " :let b:strip_trailing_whitespace = 0
  " Skip if explicitly disabled for this buffer
  if get(b:, 'strip_trailing_whitespace', 1) == 0
      return
  endif
  silent! %s/\v\S\zs[ \t]+$//e
endfunction

function! s:StripTrailingCR() abort
  if search('\r$', 'nw')
    silent! %s/\r$//e
  endif
endfunction

autocmd BufReadPost,BufWinLeave * call s:WithPreservedCursor(function('s:StripTrailingCR'))
autocmd BufWritePre * call s:WithPreservedCursor(function('s:StripTrailingWhitespace'))

" Make sure all types of requirements.txt files get syntax highlighting.
autocmd BufNewFile,BufRead requirements*.txt set ft=python

" Make sure .aliases, .bash_aliases and similar files get syntax highlighting.
autocmd BufNewFile,BufRead .*aliases* set ft=sh

autocmd BufReadPost fugitive://* set bufhidden=delete

augroup DetectPythonProject
  autocmd!
  autocmd VimEnter * call DetectProjectName()
augroup END

" Make this more specific
" augroup pytest_parse
"     autocmd!
"     autocmd QuickFixCmdPost dispatch call ParsePytestFailures()
" augroup END
