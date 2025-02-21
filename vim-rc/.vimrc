" Load plugin initialization
source ~/.vim/custom/plug.vim
" Leader key
let mapleader = " "
set shell=/bin/bash

"""""""""""""""""""""""""""""""""
" Load general configurations """
"""""""""""""""""""""""""""""""""

source ~/.vim/custom/options.vim
source ~/.vim/custom/keymaps.vim
source ~/.vim/custom/ui.vim

" Add autocommands

" Understand jsconc
autocmd FileType json syntax match Comment +\/\/.\+$+

" Remember cursor position when reopening a file
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

" Misc
filetype plugin indent on

" Enable system clipboard access
set clipboard+=unnamedplus

" WSL clipboard support (adjust path as needed)
" let s:clip = '/mnt/c/Windows/System32/clip.exe'
" if executable(s:clip)
"   augroup WSLYank
"     autocmd!
"     autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
"   augroup END
" endif

""""""""""""""""""""""""""""""""
" Load plugin configurations """
""""""""""""""""""""""""""""""""

source ~/.vim/custom/plugins/palenight.vim

" https://github.com/vim-python/python-syntax?tab=readme-ov-file
" let g:python_highlight_all = 1

" Load fzf key maps ---
set rtp+=/opt/homebrew/opt/fzf
"source ~/.vim/custom/plugins/fzf/options.vim
"source ~/.vim/custom/plugins/fzf/keymaps.vim
"source ~/.vim/custom/plugins/fzf/commands.vim
