" General settings
set nocompatible
" Allow customization via ~/.vim/ftplugin/
filetype plugin on
" Autocomplete for files in subdirectories
set path+=**
set mouse=a
set ignorecase            " Search ignoring case
set smartcase             " Do not ignore case if the search patter is uppercase
set noswapfile            " Do not leave any backup files
set tabstop=4       " Set the width of a tab character
set shiftwidth=4    " Set the number of spaces for auto-indents
set expandtab       " Use spaces instead of tab characters
set softtabstop=4   " Insert/remove 2 spaces when pressing Tab/Backspace
set wildmode=longest,list,full " enhanced command-line completion

" set timeoutlen=300    " Mapped key sequence duration (1000 ms default)
set grepprg=rg\ --vimgrep\ --smart-case
set grepformat=%f:%l:%c:%m,%f:%l:%m
