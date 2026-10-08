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
" Detect WSL (only meaningful if we're on Linux)
let g:is_wsl = 0
if g:os ==# 'Linux'
    if exists('$WSL_DISTRO_NAME') || filereadable('/proc/version') && readfile('/proc/version')[0] =~? 'microsoft'
        let g:is_wsl = 1
    endif
endif

function! MySource(file) abort
    execute 'source ' . g:vimdir . '/' . a:file
endfunction

""""""""""""""""""""""""
" Plugins (vim-plug) """
""""""""""""""""""""""""
call plug#begin(g:vimdir . '/plugged')
" Plugin list
" Plug 'sheerun/vim-polyglot'
Plug 'instant-markdown/vim-instant-markdown', {'for': 'markdown', 'do': 'yarn install'}
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-tbone'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-rsi'
Plug 'junegunn/vim-peekaboo'
Plug 'junegunn/vim-easy-align'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/fzf'
" Couldn't get it to work
" Plug 'yegappan/lsp'
Plug 'prabirshrestha/vim-lsp'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'mattn/vim-lsp-settings'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf.vim'
" fzf-utils (:FdFiles, :Grep, :RgRaw) adds commands under its own names and
" redefines none of fzf.vim's, so its order doesn't matter.
Plug 'roumail/fzf-utils'
Plug 'roumail/project-detect'
Plug 'roumail/grepscope'
Plug 'roumail/dispatch-extras'
Plug 'roumail/pytest.vim'
Plug 'roumail/scratch.vim'
Plug 'roumail/buffer-tools'
Plug 'roumail/qf-tools'
Plug 'roumail/text-tools'
Plug 'roumail/glow-preview'
" requires dependency installation using npm install -g livedown
" Plug 'shime/vim-livedown'
" Plug 'drewtempelmeyer/palenight.vim'
Plug 'danilo-augusto/vim-afterglow'
call plug#end()

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
call MySource('custom/clipboard.vim')

" Load machine-specific local overrides (e.g. g:github_enterprise_urls)
if filereadable(expand('~/.vim.local'))
    source ~/.vim.local
endif

" fzf's Vim plugin comes from Plug 'junegunn/fzf' above. README-VIM offers
" Homebrew's copy as an alternative, not an addition: added here it sits after
" plugged/fzf in rtp and stops at the g:loaded_fzf guard.
" if isdirectory('/opt/homebrew/opt/fzf')
"     set rtp+=/opt/homebrew/opt/fzf
" endif

" Plugin settings live in plugin/<name>.vim, commands in plugin/commands.vim
" and keymaps in after/plugin/keymaps.vim. Vim sources them after this file.

""""""""""""""""""""""""""""""""""""""
" Load project local configuration """
""""""""""""""""""""""""""""""""""""""
" Sourced once at startup from the directory vim was launched in
if filereadable(".vim.custom")
    so .vim.custom
endif
