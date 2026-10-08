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
  autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \ exe "normal! g`\"" |
        \ endif
augroup END

" Make sure all types of requirements.txt files get syntax highlighting.
autocmd BufNewFile,BufRead requirements*.txt set ft=python

" Make sure .aliases, .bash_aliases and similar files get syntax highlighting.
autocmd BufNewFile,BufRead .*aliases* set ft=sh

autocmd BufReadPost fugitive://* set bufhidden=delete
