call plug#begin(g:vimdir . '/plugged')
" Plugin list
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-sensible'
Plug 'instant-markdown/vim-instant-markdown', {'for': 'markdown', 'do': 'yarn install'}
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-vinegar'
" Use rg integration with fzf
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'drewtempelmeyer/palenight.vim' 
call plug#end()
