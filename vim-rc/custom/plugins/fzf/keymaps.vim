" Switch to open buffer
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>h :History<CR>
nnoremap <silent> <leader>C :Commits<CR>
" line search
nnoremap <Space>/ :Rg<Space>

" Bcommits --> current buffer
nnoremap <silent> <leader>c :BCommits<CR>

nnoremap <silent> <leader><leader> :Files<CR>
" Sibling file - Same directory
nnoremap <silent> <leader>. :Files <C-r>=expand("%:h")<CR>/<CR>
" edit a test file
nnoremap <silent> <leader>et :Files tests<CR>

" status of current Git repository whilst also allowing easy navigation to modified files.
nnoremap <silent> <leader>g :GFiles?

" Mapping selecting mappings
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

" Insert mode completion
"imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-l> <plug>(fzf-complete-line)
