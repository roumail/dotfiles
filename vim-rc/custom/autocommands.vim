
" Understand jsconc
autocmd FileType json syntax match Comment +\/\/.\+$+

" Remember cursor position when reopening a file
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

"autocmd BufRead,BufNewFile *.md,*.txt setlocal wrap " DO wrap on markdown files
augroup MarkdownSettings
  autocmd!
  " Apply these settings ONLY to markdown files
  autocmd FileType markdown setlocal wrap linebreak textwidth=0
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

augroup DetectPythonProject
  autocmd!
  autocmd VimEnter * call DetectProjectName()
augroup END

" Make this more specific
" augroup pytest_parse
"     autocmd!
"     autocmd QuickFixCmdPost dispatch call ParsePytestFailures()
" augroup END
