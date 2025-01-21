" Mappings for CoCList
" Show all diagnostics
nnoremap <silent><nowait> <leader>cl  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent><nowait> <leader>ce  :<C-u>CocList extensions<cr>
" Outline of symbols in document
nnoremap <silent><nowait> <leader>co  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent><nowait> <leader>cs  :<C-u>CocList -I symbols<cr>
nnoremap <silent><nowait> <leader>cc  :<C-u>CocList commands<cr>
" Do default action for next item
nnoremap <silent><nowait> <leader>c]  :<C-u>CocNext<CR>
" Do default action for previous item
nnoremap <silent><nowait> <leader>c[  :<C-u>CocPrev<CR>
" Resume latest coc list
" nnoremap <silent><nowait> <leader>p  :<C-u>CocListResume<CR>