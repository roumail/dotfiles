" Understand jsconc
 autocmd FileType json syntax match Comment +\/\/.\+$+

" Remember cursor position when reopening a file
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END
