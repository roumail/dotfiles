call plug#begin(g:vimdir . '/plugged')
" Plugin list
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-sensible'
Plug 'instant-markdown/vim-instant-markdown', {'for': 'markdown', 'do': 'yarn install'}
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fugitive'
" Couldn't get it to work
" Plug 'yegappan/lsp'
Plug 'prabirshrestha/vim-lsp'
Plug 'tpope/vim-unimpaired'
Plug 'mattn/vim-lsp-settings'
"Plug 'airblade/vim-gitgutter'
" Use rg integration with fzf
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'drewtempelmeyer/palenight.vim' 
call plug#end()
