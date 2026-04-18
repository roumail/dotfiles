" Write and quit shortcuts
"nnoremap <leader>q :wq<CR>

" Insert mode mappings
inoremap jj <Esc>
inoremap jk <Esc>:w<CR>
inoremap jq <Esc>:wq<CR>

" Normal mode mappings
nnoremap K i<CR><Esc>
nnoremap <leader>w :w<CR>
nnoremap <leader>x "_x
nnoremap <leader>d "_dd
nnoremap Y y$
nnoremap <leader>Y "+y$
nnoremap <leader>y "+y
nnoremap <leader>p "+p

" Current line number
nnoremap <leader>gl :let @+ =line('.')<CR>:echo "Line number copied!"<CR>
nnoremap <leader>gL :let @+ = expand('%') . ':' . line('.')<CR>:echo "File:line copied!"<CR>

" Current file relative path
nnoremap <leader>f :let @+ = @%<CR>:echo "Path copied!"<CR>
" Absolute path
nnoremap <leader>F :let @+ = expand('%:p')<CR>:echo "Absolute path copied!"<CR>
nnoremap <leader>rl :source $MYVIMRC<CR>
" open tab in terminal
nnoremap <leader>ot :tab term ++kill=term<CR>
" Open current buffer in new tab
nnoremap <silent> <leader>tt :tab split<CR>

" Save session - load session
" nnoremap <leader>ss :mksession! Session.vim<CR>
" nnoremap <leader>sl :source Session.vim<CR>
" don't overwrite yank register when changing
nnoremap c "_c
nnoremap C "_C

nnoremap <leader>q :wq<CR>
" buffer switching
" Switch to the alternate (last used) buffer
nnoremap gb :b#<CR>

" bd ends up closing the current window too
" nnoremap <leader>bc :bd<CR>
" nnoremap <silent> <leader>bc :bp\| bd #<CR>
" This function skips terminal windows and netrw
nnoremap <silent> <leader>bc :call SmartFilterClose()<CR>
nnoremap <leader>bC :bufdo bd<CR>

" Split opening
nnoremap <leader>s :split<CR>
nnoremap <leader>v :vsplit<CR>

" Split navigation
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l

nnoremap <silent> yoq :call ToggleQuickfix()<CR>

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" Visual mode mappings
" Keep VisualMode after indent with > or <
vmap < <gv
vmap > >gv

" Move Visual blocks with J and K
vnoremap <leader>d "_d
vnoremap <leader>c "_c
vnoremap <leader>y "+y
vnoremap <leader>p "+p

" vnoremap p "0p gv"
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
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
