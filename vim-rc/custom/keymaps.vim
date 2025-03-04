" Split navigation

"nnoremap <leader>h <C-w>h
"nnoremap <leader>j <C-w>j
"nnoremap <leader>k <C-w>k
"nnoremap <leader>l <C-w>l

" delete without changing buffer 
nnoremap <leader>d "_dd
noremap <leader>x "_x

" Split opening
nnoremap <leader>h :split<CR>
nnoremap <leader>v :vsplit<CR>

" Write and quit shortcuts
"nnoremap <leader>q :wq<CR>
"nnoremap <leader>w :w<CR>

" Visual mode
" Move Visual blocks with J and K
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

vnoremap <leader>d "_d
vnoremap p pgv"0y
" vnoremap p pgvy
" Keep VisualMode after indent with > or <
vmap < <gv
vmap > >gv
