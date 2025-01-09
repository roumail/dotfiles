" General settings
set nocompatible
set shell=/bin/bash
set number relativenumber
" set mouse=a
set ignorecase            " Search ignoring case
set smartcase             " Do not ignore case if the search patter is uppercase
set hlsearch              " Highlight search results
autocmd BufRead,BufNewFile *.md,*.txt setlocal wrap " DO wrap on markdown files
set nowrap                " except on markdown
set noswapfile            " Do not leave any backup files
set showmatch             " Highlight matching parentheses, brackets, and braces
set splitbelow splitright " Open splits below and to the right
set tabstop=4       " Set the width of a tab character
set shiftwidth=4    " Set the number of spaces for auto-indents
set expandtab       " Use spaces instead of tab characters
set softtabstop=4   " Insert/remove 2 spaces when pressing Tab/Backspace
set wildmode=longest,list,full " enhanced command-line completion

" set timeoutlen=300    " Mapped key sequence duration (1000 ms default)
