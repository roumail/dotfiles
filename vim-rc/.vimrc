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
    if empty($CMDER_ROOT) && isdirectory("C:\cmder")
        let $CMDER_ROOT= "C:\cmder"
    endif

    if !empty($CMDER_ROOT) 
        set shell=$CMDER_ROOT\\cmder_wrapper.cmd
        " set shell=$CMDER_ROOT\vendor\bin\vscode_init.cmd
        set shellcmdflag=/c  " Ensures :!commands work properly
        set shellxquote=     " Avoids wrapping commands in quotes
        set shellquote=      " Disables quote escaping
        set noshellslash
    else
        set shell = 'C:\Windows\System32\cmd.exe'
    endif
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

" Add netrw via packadd
if exists(':packadd')
  silent! packadd netrw
endif

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

" group for your Markdown settings 
set nowrap                " globally disable wrapping
"autocmd BufRead,BufNewFile *.md,*.txt setlocal wrap " DO wrap on markdown files
augroup MarkdownSettings
    autocmd!
    " Apply these settings ONLY to markdown files
    autocmd FileType markdown setlocal wrap linebreak textwidth=0
augroup END

" Enable system clipboard access
set clipboard=
"if g:os ==# 'Windows'
    "" On Windows, this was breaking yy
    "set clipboard=
"else
    "set clipboard+=unnamedplus
"endif

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
call MySource('custom/plugins/fzf/functions.vim')
call MySource('custom/plugins/fzf/options.vim')
call MySource('custom/plugins/fzf/keymaps.vim')
call MySource('custom/plugins/fzf/commands.vim')
call MySource('custom/plugins/lsp/keymaps.vim')
call MySource('custom/plugins/lsp/options.vim')
call MySource('custom/plugins/lsp/commands.vim')
