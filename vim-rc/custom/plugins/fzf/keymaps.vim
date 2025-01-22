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