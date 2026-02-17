" Write and quit shortcuts
"nnoremap <leader>q :wq<CR>

" Insert mode mappings
inoremap jj <Esc>

" Normal mode mappings
nnoremap <leader>w :w<CR>
nnoremap <leader>x "_x
nnoremap <leader>d "_dd
" zm, zr to increase/decrease folding
nnoremap <leader>f za

" Save session - load session
nnoremap <leader>ss :mksession! Session.vim<CR>
nnoremap <leader>sl :source Session.vim<CR>

" buffer switching
nnoremap H :bprevious<CR>
nnoremap L :bnext<CR>
" clashes with fzf searches
nnoremap <leader>bc :bd<CR>
nnoremap <leader>bC :bufdo bd<CR>

" Split opening
nnoremap <leader>s :split<CR>
nnoremap <leader>v :vsplit<CR>

" Split navigation
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l

" Location navigation
" nnoremap <leader>nb <C-o>
" nnoremap <leader>nf <C-i>
" last edit location
" nnoremap <leader>el `.

" Open netrw
nnoremap <leader>se :Explore<CR>


" Visual mode mappings
" Keep VisualMode after indent with > or <
vmap < <gv
vmap > >gv

" Move Visual blocks with J and K
vnoremap <leader>d "_d
vnoremap p "0p gv"
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
vnoremap <leader>f zf
