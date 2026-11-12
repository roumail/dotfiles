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
" fzf-utils: Vim's own <c-x><c-f> / <c-x><c-l> in the command-line window (q:)
imap <c-x><c-f> <Plug>(fzf-utils-complete-path)
imap <c-x><c-d> <Plug>(fzf-utils-complete-dir)
imap <c-x><c-l> <Plug>(fzf-utils-complete-line)
" vim-prompts: personas, #sources and flags (<Tab> picks several), in an :AiDraft
inoremap <expr> <c-x><c-a> fzf_utils#complete#with('prompts#fzf')
" vim-prompts: #commits:<hash>,<hash> from the log, in an :AiDraft
inoremap <expr> <c-x><c-g> fzf_utils#complete#with('prompts#sources#commits#fzf')
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

" Copy path:line of the cursor; capitals copy the absolute path
nnoremap <leader>gl :let @+ = expand('%') . ':' . line('.')<CR>:echo "Path:line copied!"<CR>
nnoremap <leader>gL :let @+ = expand('%:p') . ':' . line('.')<CR>:echo "Absolute path:line copied!"<CR>
" Glue the clipboard's lines, as a terminal's scrollback broke them, into one
nnoremap <leader>gj <Cmd>let @+ = substitute(@+, '\n', '', 'g')<CR>
nnoremap <leader>rl :source $MYVIMRC<CR>

" Move the window border right/left/down/up, from whichever window, on the
" <C-w> resize keys (autoload/window_border.vim)
nnoremap <silent> <C-w>> <Cmd>call window_border#move('r')<CR>
nnoremap <silent> <C-w>< <Cmd>call window_border#move('l')<CR>
nnoremap <silent> <C-w>+ <Cmd>call window_border#move('d')<CR>
nnoremap <silent> <C-w>- <Cmd>call window_border#move('u')<CR>

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

" qf-tools: open or close the quickfix window, beside unimpaired's yo* toggles
nmap yoq <Plug>(qf-tools-toggle)

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

" Live grep (fzf-utils): <leader>r, then where to search. Lowercase: type the
" query. Uppercase: the word under the cursor / the selection, with word
" boundaries
" From the working directory
nmap <leader>r/ <Plug>(fzf-utils-grep)
nmap <leader>r? <Plug>(fzf-utils-grep-word)
xmap <leader>r? <Plug>(fzf-utils-grep-word)
" The project's code, in its language (project-detect)
nmap <leader>rp <Plug>(fzf-utils-grep-code)
nmap <leader>rP <Plug>(fzf-utils-grep-code-word)
xmap <leader>rP <Plug>(fzf-utils-grep-code-word)
" The project's tests, in its language
nmap <leader>rt <Plug>(fzf-utils-grep-tests)
nmap <leader>rT <Plug>(fzf-utils-grep-tests-word)
xmap <leader>rT <Plug>(fzf-utils-grep-tests-word)
" Pick a scope (:GrepScope)
nmap <leader>rs <Plug>(fzf-utils-grep-scope)
nmap <leader>rS <Plug>(fzf-utils-grep-scope-word)
xmap <leader>rS <Plug>(fzf-utils-grep-scope-word)
" The current buffer's directory
nmap <leader>r. <Plug>(fzf-utils-grep-dir)
" Replay the last live grep
nmap <leader>rr <Plug>(fzf-utils-grep-replay)
" Prefilled to type pattern/scope
nnoremap <leader>r: :Grep

" Mapping selecting mappings
nmap <leader><tab> <plug>(fzf-maps-n)

" }}}1

"""""""""""""""""""
" git {{{1
"""""""""""""""""""

" fugitive-extras and gh-extras are used through their commands (:Diff*,
" :Branch*, :PRs)
" fugitive-extras: comment on the line / selection, into the 'Review' quickfix
" list
nmap <leader>cc <Plug>(fugitive-extras-comment)
xmap <leader>cc <Plug>(fugitive-extras-comment)
" ... in an editor split instead; picks up what <Esc> left at the prompt
nmap <leader>cd <Plug>(fugitive-extras-comment-draft)
xmap <leader>cd <Plug>(fugitive-extras-comment-draft)
" gh-extras: the same keys reply to the thread under the cursor in a :Thread /
" :Threads list (:Reply / :ReplyDraft)
augroup gh_extras_reply_keys
  autocmd!
  autocmd BufEnter gh-extras://thread* nmap <buffer> <leader>cc <Plug>(gh-extras-reply)
  autocmd BufEnter gh-extras://thread* nmap <buffer> <leader>cd <Plug>(gh-extras-reply-draft)
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

" vim-prompts: git's comment keys (<leader>cc / <leader>cd) reply to the
" agent's comment under the cursor in the :AiComments list, or in a comment's
" thread (:AiReply / :AiReplyDraft). Every quickfix window is qf, so the others
" (Review's) keep fugitive-extras'. Capitals send to a session (:AiReply! /
" :AiReplyDraft!) instead of a one-off
augroup prompts_reply_keys
  autocmd!
  autocmd FileType qf nmap <buffer><expr> <leader>cc
        \ prompts#comments#in_list() ? '<Plug>(prompts-reply)' : '<Plug>(fugitive-extras-comment)'
  autocmd FileType qf nmap <buffer><expr> <leader>cd
        \ prompts#comments#in_list() ? '<Plug>(prompts-reply-draft)' : '<Plug>(fugitive-extras-comment-draft)'
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

"""""""""""""""""""
" fzf {{{1
"""""""""""""""""""

" fzf-git pickers, on the shell's CTRL-G <letter> keys. What you pick isn't used.
" Typing CTRL-G during an incremental search waits for the next key now.
function! s:FzfGit(type) abort
  execute 'silent !bash ~/.config/shell/fzf_conf/fzf-git.sh --run' a:type '>/dev/null'
  redraw!
endfunction

cnoremap <silent> <C-g>f <Cmd>call <SID>FzfGit('files')<CR>
cnoremap <silent> <C-g>b <Cmd>call <SID>FzfGit('branches')<CR>
cnoremap <silent> <C-g>t <Cmd>call <SID>FzfGit('tags')<CR>
cnoremap <silent> <C-g>r <Cmd>call <SID>FzfGit('remotes')<CR>
cnoremap <silent> <C-g>h <Cmd>call <SID>FzfGit('hashes')<CR>
cnoremap <silent> <C-g>s <Cmd>call <SID>FzfGit('stashes')<CR>
cnoremap <silent> <C-g>l <Cmd>call <SID>FzfGit('lreflogs')<CR>
cnoremap <silent> <C-g>w <Cmd>call <SID>FzfGit('worktrees')<CR>
cnoremap <silent> <C-g>e <Cmd>call <SID>FzfGit('each_ref')<CR>

" }}}1
" }}}
