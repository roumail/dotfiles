" Write and quit shortcuts
" ============================================================
" Insert mode {{{
" ============================================================
inoremap jj <Esc>
inoremap jk <Esc>:w<CR>
inoremap jq <Esc>:wq<CR>

"""""""""""""""""""
" fzf {{{1
"""""""""""""""""""
" inoremap <expr> <c-x><c-f> fzf#vim#complete#path('rg --files')
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-l> <plug>(fzf-complete-line)
"imap <c-x><c-k> <plug>(fzf-complete-word)

" }}}1

" ============================================================
" Normal mode {{{
" ============================================================
nnoremap zm :Goyo<CR>
nnoremap K i<CR><Esc>
nnoremap <leader>w :w<CR>
nnoremap <leader>x "_x
nnoremap <leader>d "_dd
nnoremap Y y$
nnoremap gp =p
nnoremap gP =P

" Cursor at end of pasted chars
nnoremap p ]p
" Cursor at beginning of pasted line
nnoremap P [P

" Current line number
nnoremap <leader>gl :let @+ = expand('%') . ':' . line('.')<CR>:echo "File:line copied!"<CR>
nnoremap <leader>gL :let @+ =line('.')<CR>:echo "Line number copied!"<CR>

" Current file relative path
nnoremap <leader>f :let @+ = @%<CR>:echo "Path copied!"<CR>
" Absolute path
nnoremap <leader>F :let @+ = expand('%:p')<CR>:echo "Absolute path copied!"<CR>
nnoremap <leader>rl :source $MYVIMRC<CR>

" open notes in a split
nnoremap <leader>,n <Cmd>vertical term ++kill=term notes.sh<CR>
" nnoremap <leader>,n <Cmd>vertical term ++kill=term notes.sh $NOTE_DIR<CR>

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
" Navigate folds
" \@! is a negative lookahead operator, only matching {'s if there isn't a \d
" after it
nnoremap ]s /{{{\d\@!<CR>
nnoremap [s ?{{{\d\@!<CR>

nnoremap ]1 /\V{{{1<CR>
nnoremap [1 ?\V{{{1<CR>
nnoremap ]2 /\V{{{2<CR>
nnoremap [2 ?\V{{{2<CR>

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

"""""""""""""""""""
" fzf {{{1
"""""""""""""""""""

" Look up file in current directory, often project root
nnoremap <silent> <leader><leader> <Cmd>Files<CR>

" Search files only from the CURRENT buffer's directory
" nnoremap <silent> <leader>. <Cmd>Files <C-r>=expand("%:h")<CR>/<CR>

" status of current Git repository whilst also allowing easy navigation to modified files.
nnoremap <silent> <leader>og <Cmd>GFiles?<CR>

" Switch to open buffer
nnoremap <leader>ob <Cmd>Buffers<CR>

noremap <buffer> <leader>rr <Cmd>call fzf_utils#live_grep#replay()<CR>
" Fuzzy search scoped to the current buffer's directory
nnoremap <silent> <leader>r. <Cmd>execute 'Grep -- ' . expand('%:.:h') . '/'<CR>
" Line search from project root directory
nnoremap <silent> <leader>r/ <Cmd>Grep<CR>
" Prefilled to type pattern/scope
nnoremap <leader>r: :Grep

" Scoped searches (Standard)
nnoremap <leader>r <Cmd>GrepScope<CR>
" Search for word under cursor
" Word with boundaries
nnoremap <silent> <leader>rw <Cmd>execute 'GrepScope' '\b' . expand('<cword>') . '\b'<CR>
" Word without boundaries
" nnoremap <silent> <leader>rW <Cmd>execute 'GrepScope' expand('<cword>')<CR>

" Mapping selecting mappings
nmap <leader><tab> <plug>(fzf-maps-n)

" }}}1

"""""""""""""""""""
" lsp {{{1
"""""""""""""""""""

function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  setlocal signcolumn=yes
  if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
  nmap <buffer> gd <plug>(lsp-definition)
  nmap <buffer> gi <plug>(lsp-implementation)
  nmap <buffer> gr <plug>(lsp-references)
  nmap <buffer> <leader>gt <plug>(lsp-type-definition)
  " nnoremap <plug>(lsp-declaration)
  " nnoremap <plug>(lsp-peek-declaration)

  nmap <buffer> <leader>pd <plug>(lsp-peek-definition)
  nmap <buffer> <leader>pt <plug>(lsp-peek-type-definition)
  " nnoremap <plug>(lsp-preview-close)
  " nnoremap <plug>(lsp-preview-focus)
  " not available
  " nmap <buffer> <leader>pi <plug>(lsp-peek-implementation)
  " nnoremap <plug>(lsp-code-lens)
  " Map 'Leader + f' to focus the LSP popup
  nmap <buffer> <leader>pf <plug>(lsp-preview-focus)
  " nnoremap <plug>(lsp-document-symbol)
  nmap <buffer> gs <plug>(lsp-document-symbol-search)
  nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
  " nnoremap <plug>(lsp-workspace-symbol)
  " nnoremap <plug>(lsp-workspace-symbol-search)
  nmap <buffer> <leader>rn <plug>(lsp-rename)
  " nnoremap <plug>(lsp-code-action)
  nmap <buffer> <leader>ca <plug>(lsp-code-action)
  " nnoremap <plug>(lsp-code-action-float)
  " nnoremap <plug>(lsp-code-action-preview)
  nmap <buffer> <leader>ch <plug>(lsp-hover)
  " nnoremap <plug>(lsp-hover)
  " nnoremap <plug>(lsp-hover-float)
  nmap <buffer> [g <plug>(lsp-previous-diagnostic)
  nmap <buffer> ]g <plug>(lsp-next-diagnostic)
  " nnoremap <plug>(lsp-hover-preview)
  " nnoremap <plug>(lsp-document-range-format)
  " xnoremap <plug>(lsp-document-range-format)

  " let g:lsp_format_sync_timeout = 1000
  " autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')

  " refer to doc to add more commands
  nnoremap <buffer> <leader>md :MyToggleLSPDiagnostics<CR>zz
endfunction

augroup lsp_install
  au!
  " call s:on_lsp_buffer_enabled only for languages that has the server registered.
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" }}}1
" }}}

" ============================================================
" Visual mode {{{
" ============================================================
" Keep VisualMode after indent with > or <
vmap < <gv
vmap > >gv

" vnoremap d "_d
vnoremap c "_c

" vnoremap p "0p gv"
"Search inside visual selection
"for example to search for the in selection, complete the command /%Vthe
" g/ allows retaining v/term motion
vnoremap g/ <Esc>/\%V
"Search & replace inside visual selection
"for example to replace the with THE in selection, complete the command :%s/\%Vthe/THE/g
vnoremap <leader>r :s/
" vnoremap <leader>r <Esc>:%s/\%V
" Move Visual blocks with J and K
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Clashes with saving file to system registry
" vnoremap <leader>f zf
" Don't overwrite register with selection, losing previous yank
" xnoremap p p<Esc>
xnoremap p "_dP<Esc>

"""""""""""""""""""
" fzf {{{1
"""""""""""""""""""

" Visual mode
" :History:, :History/ for command, and search history
"nnoremap <leader>h :History<CR>
" History of commits to current file, BCommits
"nnoremap <silent> <leader>C <Cmd>Commits<CR>
" Bcommits --> current buffer
" nnoremap <silent> <leader>c <Cmd>BCommits<CR>
xnoremap <silent> <leader>rw y:<C-u>execute 'GrepScope' '\b' . getreg('"') . '\b'<CR>
" xnoremap <silent> <leader>rW y:<C-u>execute 'GrepScope' getreg('"')<CR>
xmap <leader><tab> <plug>(fzf-maps-x)

" }}}1
" }}}

" ============================================================
" Terminal mode {{{
" ============================================================
tnoremap <Esc><Esc> <C-w>N
tnoremap <S-Tab> <C-w>:tabprevious<CR>
tnoremap <Esc>h <C-w>h
tnoremap <Esc>j <C-w>j
tnoremap <Esc>k <C-w>k
tnoremap <Esc>l <C-w>l

" }}}

" ============================================================
" Command mode {{{
" ============================================================

cnoremap <C-K> <C-\>e{-> slice(getcmdline(), 0, getcmdpos() - 1)}()<CR>
cnoreabbrev WQ wq
cnoreabbrev Wq wq
cnoreabbrev Q q
cnoreabbrev Qa qa
cnoreabbrev QA qa

" }}}
