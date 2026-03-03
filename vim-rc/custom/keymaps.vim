" Write and quit shortcuts
"nnoremap <leader>q :wq<CR>

" Insert mode mappings
inoremap jj <Esc>
inoremap jk <Esc>:w<CR>
inoremap jq <Esc>:wq<CR>

" Normal mode mappings
nnoremap <leader>w :w<CR>
nnoremap <leader>x "_x
nnoremap <leader>d "_dd
" zm, zr to increase/decrease folding
" zM, zR for unfolfing/collapsing all
nnoremap <leader>f :let @+ = @%<CR>:echo "Path copied to clipboard!"<CR>
nnoremap <leader>rl :source $MYVIMRC<CR>
" open tab in terminal
nnoremap <leader>ot :tab term ++kill=term<CR>

" Save session - load session
" nnoremap <leader>ss :mksession! Session.vim<CR>
" nnoremap <leader>sl :source Session.vim<CR>

nnoremap <leader>q :wq<CR>
" buffer switching
" Switch to the alternate (last used) buffer
nnoremap gb :b#<CR>
" nnoremap H :bprevious<CR>
" nnoremap L :bnext<CR>
nnoremap <silent> <leader>bc :bp\| bd #<CR>
" bd ends up closing the current window too
" nnoremap <leader>bc :bd<CR>
nnoremap <leader>bC :bufdo bd<CR>

" Split opening
nnoremap <leader>s :split<CR>
nnoremap <leader>v :vsplit<CR>

" Split navigation
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l

" Open netrw
nnoremap <leader>se :Explore<CR>


" Visual mode mappings
" Keep VisualMode after indent with > or <
vmap < <gv
vmap > >gv

" Move Visual blocks with J and K
vnoremap <leader>d "_d
" vnoremap p "0p gv"
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
" Clashes with saving file to system registry
" vnoremap <leader>f zf
" Don't overwrite register with selection, losing previous yank
" xnoremap p p<Esc>
xnoremap p "_dP<Esc>
" terminal input mode mapping
tnoremap <Esc><Esc> <C-w>N
tnoremap <S-Tab> <C-w>:tabprevious<CR>
tnoremap <Esc>h <C-w>h
tnoremap <Esc>j <C-w>j
tnoremap <Esc>k <C-w>k
tnoremap <Esc>l <C-w>l
