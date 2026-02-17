" Configuring pyright with 
" https://github.com/yegappan/lsp
" if executable('pyright-langserver')
"     au User LspSetup call LspAddServer([#{
"         \  name: 'pyright',
"         \  filetype: 'python',
"         \  path: exepath('pyright-langserver'),
"         \  args: ['--stdio'],
"         \  workspaceConfig: #{
"         \    python: #{
"         \      pythonPath: 'python3'
"         \  }}
"         \ }])
" endif

if executable('pyright-langserver')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pyright',
        \ 'cmd': {server_info->['pyright-langserver', '--stdio']},
        \ 'allowlist': ['python'],
        \ 'root_uri':{server_info->lsp#utils#path_to_uri(
        \  lsp#utils#find_nearest_parent_file_directory(
        \    lsp#utils#get_buffer_path(),
        \    ['pyrightconfig.json', 'pyproject.toml', '.git/']
        \  ))},
        \ 'config': {
        \     'python': {
        \         'analysis': {
        \             'typeCheckingMode': 'off',
        \             'diagnosticsMode': 'off'
        \         }
        \     }
        \ },
  \ })
endif


function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> gr <plug>(lsp-references)
    " clashes with go to tab
    " nmap <buffer> gt <plug>(lsp-type-definition)
  " nnoremap <plug>(lsp-type-definition)
  " nnoremap <plug>(lsp-peek-type-definition)
  " nnoremap <plug>(lsp-declaration)
  " nnoremap <plug>(lsp-peek-declaration)
   
    nmap <buffer> <leader>pd <plug>(lsp-peek-definition)
    nmap <buffer> <leader>pi <plug>(lsp-peek-implementation)
  " nnoremap <plug>(lsp-hover)
  " nnoremap <plug>(lsp-hover-float)
  " nnoremap <plug>(lsp-hover-preview)
  " nnoremap <plug>(lsp-preview-close)
  " nnoremap <plug>(lsp-preview-focus)
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
  " nnoremap <plug>(lsp-code-action-float)
  " nnoremap <plug>(lsp-code-action-preview)
    nmap <buffer> <leader>ca <plug>(lsp-code-action)
    nmap <buffer> <leader>cd  <plug>(lsp-hover)
  " nnoremap <plug>(lsp-document-range-format)
  " xnoremap <plug>(lsp-document-range-format)

    " let g:lsp_format_sync_timeout = 1000
    " autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
    
    " refer to doc to add more commands
endfunction

" augroup LspPopupCustom
"     autocmd!
"     " Once you jump into the popup, 'q' will close it and jump back
"     autocmd User lsp_float_opened nmap <buffer> q <plug>(lsp-preview-close)
" augroup END

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
