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
if executable('ty')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'ty',
        \ 'cmd': {server_info->['ty', 'server']},
        \ 'allowlist': ['python'],
  \ })
endif


" augroup LspPopupCustom
"     autocmd!
"     " Once you jump into the popup, 'q' will close it and jump back
"     autocmd User lsp_float_opened nmap <buffer> q <plug>(lsp-preview-close)
" augroup END

