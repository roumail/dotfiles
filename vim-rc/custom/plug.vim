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
" These replace fzf.vim commands with `command!`, so the plugin loaded last
" wins. Plugins load in Plug order: keep them below fzf.vim.
"   fzf-utils:    :Files (fd source), :Buffers
"   fzf-utils-rg: :Rg
Plug 'roumail/fzf-utils'
Plug 'roumail/fzf-utils-rg'
Plug 'roumail/project-detect'
Plug 'roumail/grepscope'
Plug 'roumail/dispatch-extras'
Plug 'roumail/pytest.vim'
Plug 'roumail/scratch.vim'
Plug 'roumail/buffer-tools'
Plug 'roumail/qf-tools'
Plug 'roumail/text-tools'
Plug 'roumail/glow-preview'
Plug 'roumail/vim-lsp-extras'
" requires dependency installation using npm install -g livedown
" Plug 'shime/vim-livedown'
" Plug 'drewtempelmeyer/palenight.vim'
Plug 'danilo-augusto/vim-afterglow'
call plug#end()
