" Switch to open buffer
nnoremap <leader>b :Buffers<CR>
" :History:, :History/ for command, and search history
"nnoremap <leader>h :History<CR>
" History of commits to current file, BCommits
"nnoremap <silent> <leader>C :Commits<CR>
" Bcommits --> current buffer
" nnoremap <silent> <leader>c :BCommits<CR>

" line search from directory of current buffer down
" nnoremap <Space>/ :Rg<Space>
nnoremap <silent> <leader>. :call LiveSiblingSearch()<CR>
" RgRegex
" Line search from project root
nnoremap <silent> <Space>/ :call LiveProjectSearch()<CR>
" Search files only from the CURRENT buffer's directory
nnoremap <silent> <leader>. :Files <C-r>=expand("%:h")<CR>/<CR>


nnoremap <silent> <leader><leader> :Files<CR>

" edit a test file
nnoremap <silent> <leader>et :Files tests<CR>

" status of current Git repository whilst also allowing easy navigation to modified files.
nnoremap <silent> <leader>g :GFiles?<CR>

" Mapping selecting mappings
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

" Insert mode completion
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-l> <plug>(fzf-complete-line)
"imap <c-x><c-k> <plug>(fzf-complete-word)
