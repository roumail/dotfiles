" Understand jsconc
autocmd FileType json syntax match Comment +\/\/.\+$+

" Make sure all types of requirements.txt files get syntax highlighting.
autocmd BufNewFile,BufRead requirements*.txt set ft=python

" Make sure .aliases, .bash_aliases and similar files get syntax highlighting.
autocmd BufNewFile,BufRead .*aliases* set ft=sh

autocmd BufReadPost fugitive://* set bufhidden=delete
