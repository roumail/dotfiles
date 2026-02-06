" This tells the plugin how to start pyright using lsp plugin
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

" In case you want to enable diagnosticMode, and specify specific overrides
" \             'diagnosticSeverityOverrides': {
" \                 'reportGeneralTypeIssues': 'warning',
" \                 'analyzeUnannotatedFunctions': 'warning',
" \                 'strictParameterNoneValue': 'warning',
" \                 'reportOptionalSubscript': 'warning',
" \                 'reportOptionalMemberAccess': 'warning',
" \                 'reportOptionalCall': 'warning',
" \                 'reportOptionalIterable': 'warning',
" \                 'reportOptionalContextManager': 'warning',
" \                 'reportOptionalOperand': 'warning',
" \                 'reportDeprecated': 'warning',
" \             },

if executable('pyright-langserver')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pyright',
        \ 'cmd': {server_info->['pyright-langserver', '--stdio']},
        \ 'allowlist': ['python'],
        \ 'root_uri':{server_info->lsp#utils#path_to_uri(
        \  lsp#utils#find_nearest_parent_file_directory(
        \    lsp#utils#get_buffer_path(),
        \    ['pyrightconfig.json', '.git/']
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
    " add peaks
    " nnoremap <leader>gd <cmd>LspGotoDefinition<CR>
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gs <plug>(lsp-document-symbol-search)
    nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gi <plug>(lsp-implementation)
    " clashes with go to tab
    " nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    nmap <buffer> <leader>ca <plug>(lsp-code-action)
    " nmap <buffer> [g <plug>(lsp-previous-diagnostic)
    " nmap <buffer> ]g <plug>(lsp-next-diagnostic)
    nmap <buffer> <leader>cd  <plug>(lsp-hover)
    " nnoremap <buffer> <expr><c-f> lsp#scroll(+4)
    " nnoremap <buffer> <expr><c-d> lsp#scroll(-4)

    " let g:lsp_format_sync_timeout = 1000
    " autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
    
    " refer to doc to add more commands
endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
