" Write and quit shortcuts
" ============================================================
" Insert mode {{{
" ============================================================
inoremap jj <Esc>
inoremap k{ {{{
inoremap j{ }}}
inoremap jk <Esc>:w<CR>
inoremap jq <Esc>:wq<CR>

"""""""""""""""""""
" fzf {{{1
"""""""""""""""""""
inoremap <expr> <c-x><c-f> fzf#vim#complete#path('rg --files')
imap <c-x><c-l> <plug>(fzf-complete-line)
" vim-prompts: personas, #sources and flags (<Tab> picks several), in an :AiDraft
inoremap <expr> <c-x><c-a> fzf#vim#complete(prompts#fzf())
" vim-prompts: #commits:<hash>,<hash> from the log, in an :AiDraft
inoremap <expr> <c-x><c-g> fzf#vim#complete(prompts#sources#commits#fzf())
"imap <c-x><c-k> <plug>(fzf-complete-word)

" }}}1

" ============================================================
" Normal mode {{{
" ============================================================
nnoremap <leader>z :Goyo<CR>
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
" buffer switching (gb, the alternate buffer, comes with buffer-tools)

" bd ends up closing the current window too
" nnoremap <leader>bc :bd<CR>
" nnoremap <silent> <leader>bc :bp\| bd #<CR>
" This function skips terminal windows and netrw
nmap <leader>bc <Plug>(buffer-tools-close)
nnoremap <leader>bC :bufdo bd<CR>

" Split opening
nnoremap <leader>s :split<CR>
nnoremap <leader>v :vsplit<CR>

" Split navigation
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l
" inverse of terminal mode
nnoremap <S-Tab> :tabnext<CR>

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

"""""""""""""""""""
" fzf {{{1
"""""""""""""""""""

" Look up file in current directory, often project root (fd listing, fzf-utils)
nmap <silent> <leader><leader> <Plug>(fzf-utils-files)

" Search files only from the CURRENT buffer's directory
" nnoremap <silent> <leader>. <Cmd>FdFiles <C-r>=expand("%:h")<CR>/<CR>

" status of current Git repository whilst also allowing easy navigation to modified files.
nnoremap <silent> <leader>og <Cmd>GFiles?<CR>

" Switch to open buffer
nnoremap <leader>ob <Cmd>Buffers<CR>

" Browse search history (populated by live grep queries too)
nnoremap <silent> <leader>rh <Cmd>History/<CR>

" Live grep (fzf-utils)
nmap <leader>rr <Plug>(fzf-utils-grep-replay)
" Fuzzy search scoped to the current buffer's directory
nmap <leader>r. <Plug>(fzf-utils-grep-dir)
" Line search from project root directory
nmap <leader>r/ <Plug>(fzf-utils-grep)
" Prefilled to type pattern/scope
nnoremap <leader>r: :Grep

" The project's code / tests, in its language (gw / gW come with fzf-utils)
nnoremap <silent> <leader>rp <Cmd>call fzf_utils#grep_code()<CR>
nnoremap <silent> <leader>rt <Cmd>call fzf_utils#grep_tests()<CR>
" Scoped searches (:GrepScope)
nmap <leader>rs <Plug>(fzf-utils-grep-scope)
" Word under cursor / selection, with word boundaries
nmap <leader>rw <Plug>(fzf-utils-grep-scope-word)
xmap <leader>rw <Plug>(fzf-utils-grep-scope-word)

" Mapping selecting mappings
nmap <leader><tab> <plug>(fzf-maps-n)

" }}}1

"""""""""""""""""""
" git {{{1
"""""""""""""""""""

" fugitive-extras and gh-extras are used through their commands (:Diff*,
" :Branch*, :PRs)
" vim-review: comment on the line / selection, into the 'Review' quickfix list
nmap <leader>cc <Plug>(review-comment)
xmap <leader>cc <Plug>(review-comment)
" ... in an editor split instead; picks up what <Esc> left at the prompt
nmap <leader>cd <Plug>(review-comment-draft)
xmap <leader>cd <Plug>(review-comment-draft)
" gh-extras: the same keys reply to the thread under the cursor in a :Thread /
" :Threads list (:Reply / :ReplyDraft)
augroup gh_extras_reply_keys
  autocmd!
  autocmd BufEnter gh-extras://thread* nmap <buffer> <leader>cc <Plug>(gh-extras-reply)
  autocmd BufEnter gh-extras://thread* nmap <buffer> <leader>cd <Plug>(gh-extras-reply-draft)
augroup END
" vim-prompts: ... and to the agent's comment under the cursor in the
" :AiComments list, or in a comment's thread (:AiReply / :AiReplyDraft). Every
" quickfix window is qf, so the others (Review's) keep vim-review's. Capitals
" send to a session (:AiReply! / :AiReplyDraft!) instead of a one-off
augroup prompts_reply_keys
  autocmd!
  autocmd FileType qf nmap <buffer><expr> <leader>cc
        \ prompts#comments#in_list() ? '<Plug>(prompts-reply)' : '<Plug>(review-comment)'
  autocmd FileType qf nmap <buffer><expr> <leader>cd
        \ prompts#comments#in_list() ? '<Plug>(prompts-reply-draft)' : '<Plug>(review-comment-draft)'
  autocmd FileType qf nmap <buffer><expr> <leader>cC
        \ prompts#comments#in_list() ? '<Plug>(prompts-reply-session)' : ''
  autocmd FileType qf nmap <buffer><expr> <leader>cD
        \ prompts#comments#in_list() ? '<Plug>(prompts-reply-draft-session)' : ''
  autocmd BufEnter ai-thread://* nmap <buffer> <leader>cc <Plug>(prompts-reply)
  autocmd BufEnter ai-thread://* nmap <buffer> <leader>cd <Plug>(prompts-reply-draft)
  autocmd BufEnter ai-thread://* nmap <buffer> <leader>cC <Plug>(prompts-reply-session)
  autocmd BufEnter ai-thread://* nmap <buffer> <leader>cD <Plug>(prompts-reply-draft-session)
augroup END

" }}}1

"""""""""""""""""""
" ai {{{1
"""""""""""""""""""

" vim-prompts: types :Ai / :AiDraft (:'<,'>Ai from visual) to finish
nmap <leader>aa <Plug>(prompts-ask)
xmap <leader>aa <Plug>(prompts-ask)
nmap <leader>ad <Plug>(prompts-draft)
xmap <leader>ad <Plug>(prompts-draft)

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
  nnoremap <buffer> <leader>md <Cmd>ToggleLspDiagnostics<CR>zz
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
vnoremap <leader>s :s/
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
" some strange inconsistent behaviour happens with viw and p, somethings ahead
" and sometimes behind
xnoremap p "_dP<Esc>
" xnoremap p "_dp<Esc>

"""""""""""""""""""
" fzf {{{1
"""""""""""""""""""

" Visual mode
" :History:, :History/ for command, and search history
"nnoremap <leader>h :History<CR>
xmap <leader><tab> <plug>(fzf-maps-x)

" }}}1
" }}}

" ============================================================
" Terminal mode {{{
" ============================================================
" Agents (claude, copilot) use Esc Esc themselves: it goes through to them
function! s:esc_esc() abort
  return bufname() =~# '^!''\=\%(\S*/\)\=\%(claude\|copilot\)\>' ? "\<Esc>\<Esc>" : "\<C-w>N"
endfunction
tnoremap <expr> <Esc><Esc> <SID>esc_esc()
" Claude's classic renderer leaves its history in Vim's scrollback, which only
" Terminal-Normal mode shows: the wheel goes there (copilot scrolls itself)
tnoremap <expr> <ScrollWheelUp> bufname() =~# '^!''\=\%(\S*/\)\=claude\>'
      \ ? "\<C-w>N3\<C-y>" : "\<ScrollWheelUp>"
tnoremap <C-w>n <C-w>N
tnoremap <S-Tab> <C-w>:tabprevious<CR>
tnoremap <Esc>h <C-w>h
tnoremap <Esc>j <C-w>j
tnoremap <Esc>k <C-w>k
tnoremap <Esc>l <C-w>l
tnoremap <silent> <Esc>pp <C-w>:q!<CR>

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
