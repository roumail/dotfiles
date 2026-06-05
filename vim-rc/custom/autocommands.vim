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

augroup StripTrailingCR
  autocmd!
  " Trigger on: Read Post, Write Pre (before saving), and exiting a window
  autocmd BufReadPost,BufWritePre,BufWinLeave *
        \ if !&readonly && &modifiable && search('\r$', 'nw') |
        \   let save_cursor = getpos(".") |
        \   silent! %s/\r$//e |
        \   call setpos('.', save_cursor) |
        \ endif
augroup END

" Make sure all types of requirements.txt files get syntax highlighting.
autocmd BufNewFile,BufRead requirements*.txt set ft=python

" Make sure .aliases, .bash_aliases and similar files get syntax highlighting.
autocmd BufNewFile,BufRead .*aliases* set ft=sh

autocmd BufReadPost fugitive://* set bufhidden=delete
" Strip trailing whitespace
autocmd BufWritePre * %s/\s\+$//e

augroup DetectPythonProject
  autocmd!
  autocmd VimEnter * call DetectProjectName()
augroup END

" Make this more specific
" augroup pytest_parse
"     autocmd!
"     autocmd QuickFixCmdPost dispatch call ParsePytestFailures()
" augroup END
