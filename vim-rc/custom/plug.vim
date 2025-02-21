" Setting up shell is complicated on windows, and therefore, maybe it's better to 
" keep plugins light and clone yourself, using start directory and rtp path
"set shell=cmd.exe
"set shellcmdflag=-c
"set shellslash
"set guioptions+=!     " don't open cmd.exe-window on windows in case of :!

"command! MyPlugUpdate   :set shell=cmd.exe shellcmdflag=/c noshellslash guioptions-=! <bar> noautocmd PlugUpdate
" PlugInstall
"command! MyPlugInstall  :set shell=cmd.exe shellcmdflag=/c noshellslash guioptions-=! <bar> noautocmd PlugInstall
" PlugClean
"command! MyPlugClean    :set shell=cmd.exe shellcmdflag=/c noshellslash guioptions-=! <bar> noaucmd PlugClean

" Installing using start directory and pack looks like this for vim/sensible
" mkdir -p ~/.vim/pack/tpope/start
" cd ~/.vim/pack/tpope/start
" git clone https://tpope.io/vim/sensible.git
" https://vi.stackexchange.com/questions/45938/manually-installing-plugins
" https://vi.stackexchange.com/a/12996
call plug#begin("~/vimfiles/plugged")
" Plugin list
"Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-commentary'
" Use rg integration with fzf
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'drewtempelmeyer/palenight.vim' 
call plug#end()
