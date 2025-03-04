" Split navigation
"map <C-h> <C-w>h
"map <C-j> <C-w>j
"map <C-k> <C-w>k
"map <C-l> <C-w>l

" Split opening
nnoremap <leader>h :split<CR>
nnoremap <leader>v :vsplit<CR>

" Write and quit shortcuts
"nnoremap <leader>q :wq<CR>
"nnoremap <leader>w :w<CR>


" Keep VisualMode after indent with > or <
vmap < <gv
vmap > >gv

" Move Visual blocks with J and K
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" delete without changing buffer 
nnoremap <leader>d "_dd
vnoremap <leader>d "_d
noremap <leader>x "_x

