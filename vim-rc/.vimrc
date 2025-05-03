" 1. Detect OS if not already set
if !exists("g:os")
    if has("win64") || has("win32") || has("win16")
        let g:os = "Windows"
    elseif executable('uname')
        let uname_output = system('uname')
        if uname_output =~? 'MINGW' || uname_output =~? 'CYGWIN' || uname_output =~? 'MSYS'
            let g:os = "Windows"
        elseif uname_output =~? 'Darwin'
            let g:os = "MacOS"
        else
            let g:os = substitute(system('uname'), '\n', '', '')
        endif
    endif
endif

" 2. Set paths and shell depending on OS
if g:os ==# 'Windows'
    " On Windows, the default user runtime directory is ~/vimfiles
    let g:vimdir = expand('~/vimfiles')
    " set shellcmdflag=/c
    " set noshellslash
    " set shell = 'C:\Windows\System32\cmd.exe'
else
    " On Unix-like systems, it's typically ~/.vim
    let g:vimdir = expand('~/.vim')
    if g:os ==# 'MacOS'
        set shell=/bin/zsh
    else
        set shell=/bin/bash
    endif
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

" Make sure all types of requirements.txt files get syntax highlighting.
autocmd BufNewFile,BufRead requirements*.txt set ft=python

" Make sure .aliases, .bash_aliases and similar files get syntax highlighting.
autocmd BufNewFile,BufRead .*aliases* set ft=sh

""""""""""""""""""""""""""""""""
" Load plugin configurations """
""""""""""""""""""""""""""""""""

" https://github.com/vim-python/python-syntax?tab=readme-ov-file
let g:python_highlight_all = 1
let g:instant_markdown_autostart = 0

" Load fzf key maps ---
if isdirectory('/opt/homebrew/opt/fzf')
    set rtp+=/opt/homebrew/opt/fzf
endif
call MySource('custom/plugins/fzf/options.vim')
call MySource('custom/plugins/fzf/keymaps.vim')
call MySource('custom/plugins/fzf/commands.vim')
