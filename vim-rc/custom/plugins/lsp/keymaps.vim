" --- General Vim Settings ---
set signcolumn=yes
set completeopt=menuone,noselect

" --- Keybindings  ---
nnoremap K <cmd>LspHover<CR>
nnoremap <leader>gd <cmd>LspGotoDefinition<CR>
nnoremap <leader>gr <cmd>LspShowReferences<CR>
nnoremap <leader>ca <cmd>LspCodeAction<CR>
nnoremap <leader>rn <cmd>LspRename<CR>
" nnoremap [d <cmd>LspDiagPrev<CR>
" nnoremap ]d <cmd>LspDiagNext<CR>


