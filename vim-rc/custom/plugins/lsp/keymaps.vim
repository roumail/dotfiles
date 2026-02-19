
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
    nmap <buffer> <leader>pi <plug>(lsp-peek-implementation)
  " nnoremap <plug>(lsp-preview-close)
  " nnoremap <plug>(lsp-preview-focus)
  " not available
  " nnoremap <plug>(lsp-code-lens) 
    " Map 'Leader + f' to focus the LSP popup
    nmap <buffer> <leader>f <plug>(lsp-preview-focus)
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
  " nnoremap <plug>(lsp-hover-preview)
    nmap <buffer> <leader>cd  <plug>(lsp-hover)
  " nnoremap <plug>(lsp-document-range-format)
  " xnoremap <plug>(lsp-document-range-format)

    " let g:lsp_format_sync_timeout = 1000
    " autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
    
    " refer to doc to add more commands
endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
