" Write and quit shortcuts
"nnoremap <leader>q :wq<CR>

" Insert mode mappings
inoremap jj <Esc>

" Normal mode mappings
nnoremap <leader>w :w<CR>
nnoremap <leader>x "_x
nnoremap <leader>d "_dd

" :tabn 3 → Goes to the 3rd tab
" gt / :tabnext → Next tab
" gT / :tabprevious → Previous tab
" You can also prefix gt with a count:
" 3gt → Go to tab 3
" 1gt → Go to tab 1
" :tabnew         → Open a new tab page with an empty window
" :tabedit <file> → Open <file> in a new tab page
" :tabs           → List all open tab pages
" :tabnext / :tabn    → Go to next tab page
" :tabprevious / :tabp → Go to previous tab page
" :tabfirst       → Go to the first tab page
" :tablast        → Go to the last tab page
" :tabclose       → Close the current tab page
" :tabonly        → Close all other tab pages
"
" Further mapping options
" nnoremap <leader>tn :tabnew<CR>
" nnoremap <leader>to :tabonly<CR>
" nnoremap <leader>tc :tabclose<CR>
" nnoremap <S-Tab>    :tabprevious<CR>
" nnoremap <Tab>      :tabnext<CR>
" buffer switching
nnoremap H :bprevious<CR>
nnoremap L :bnext<CR>
nnoremap <leader>bc :bd<CR>
nnoremap <leader>bc :bufdo bd<CR>

" Split opening
nnoremap <leader>s :split<CR>
nnoremap <leader>v :vsplit<CR>

" Split navigation
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l

" Location navigation
nnoremap <leader>nb <C-o>
nnoremap <leader>nf <C-i>
" last edit location
nnoremap <leader>el `.

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