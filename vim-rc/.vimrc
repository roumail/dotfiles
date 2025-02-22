" 1. Detect OS if not already set
if !exists("g:os")
    if has("win64") || has("win32") || has("win16")
        let g:os = "Windows"
    else
        let g:os = substitute(system('uname'), '\n', '', '')
    endif
endif

" 2. Set paths and shell depending on OS
if g:os ==# 'Windows'
    " On Windows, the default user runtime directory is ~/vimfiles
    let g:vimdir = expand('~/vimfiles')
else
    " On Unix-like systems, it's typically ~/.vim
    let g:vimdir = expand('~/.vim')
    " On non-Windows, set shell to bash
    set shell=/bin/bash
endif

function! MySource(file) abort
    execute 'source ' . g:vimdir . '/' . a:file
endfunction

" Load plugin initialization
call MySource('custom/plug.vim')

" Leader key
let mapleader = " "

"""""""""""""""""""""""""""""""""
" Load general configurations """
"""""""""""""""""""""""""""""""""
call MySource('custom/options.vim')
call MySource('custom/keymaps.vim')
call MySource('custom/ui.vim')

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
call MySource('custom/plugins/palenight.vim')

" https://github.com/vim-python/python-syntax?tab=readme-ov-file
" let g:python_highlight_all = 1

" Load fzf key maps ---
if isdirectory('/opt/homebrew/opt/fzf')
    set rtp+=/opt/homebrew/opt/fzf
endif
call MySource('custom/plugins/fzf/options.vim')
call MySource('custom/plugins/fzf/keymaps.vim')
call MySource('custom/plugins/fzf/commands.vim')
