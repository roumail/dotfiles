" Look up file in current directory, often project root
nnoremap <silent> <leader><leader> <Cmd>Files<CR>

" edit a test file
" nnoremap <silent> <leader>et <Cmd>FZF tests<CR>
" Search files only from the CURRENT buffer's directory
" nnoremap <silent> <leader>. <Cmd>Files <C-r>=expand("%:h")<CR>/<CR>

" status of current Git repository whilst also allowing easy navigation to modified files.
nnoremap <silent> <leader>og <Cmd>GFiles?<CR>

" Switch to open buffer
nnoremap <leader>ob <Cmd>Buffers<CR>

" Fuzzy search scoped to the current buffer's directory
nnoremap <silent> <leader>r. <Cmd>execute 'Grep -- ' . expand('%:.:h') . '/'<CR>
" Line search from project root directory
nnoremap <silent> <leader>r/ <Cmd>Grep<CR>
" Prefilled to type pattern/scope
nnoremap <leader>r: :Grep
" Prefilled to type pattern
nnoremap <leader>gr: :GrepScope

" Scoped searches (Standard)
nnoremap <leader>r <Cmd>GrepScope<CR>
" Search for word under cursor
" Word with boundaries
nnoremap <silent> <leader>rw <Cmd>execute 'GrepScope' '\b' . expand('<cword>') . '\b'<CR>
" Word without boundaries
nnoremap <silent> <leader>rW <Cmd>execute 'GrepScope' expand('<cword>')<CR>

" Mapping selecting mappings
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

" Insert mode completion
" inoremap <expr> <c-x><c-f> fzf#vim#complete#path('rg --files')
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-l> <plug>(fzf-complete-line)
"imap <c-x><c-k> <plug>(fzf-complete-word)

" Visual mode
" :History:, :History/ for command, and search history
"nnoremap <leader>h :History<CR>
" History of commits to current file, BCommits
"nnoremap <silent> <leader>C <Cmd>Commits<CR>
" Bcommits --> current buffer
" nnoremap <silent> <leader>c <Cmd>BCommits<CR>
xnoremap <silent> <leader>rw y:<C-u>execute 'GrepScope' '\b' . getreg('"') . '\b'<CR>
xnoremap <silent> <leader>rW y:<C-u>execute 'GrepScope' getreg('"')<CR>
