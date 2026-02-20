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

" Toggling diagnostics and virtual text {{{
autocmd BufEnter * let b:my_lsp_diagnostics_enabled = 1
function! s:MyToggleLSPDiagnostics()
	" source: https://github.com/prabirshrestha/vim-lsp/issues/1312
    if !exists('b:my_lsp_diagnostics_enabled')
		" Ensure the buffer variable is defined
        let b:my_lsp_diagnostics_enabled = 1
    endif
    if b:my_lsp_diagnostics_enabled == 1
        call lsp#disable_diagnostics_for_buffer()
        let b:my_lsp_diagnostics_enabled = 0
        echo "LSP Diagnostics : OFF"
    else
        call lsp#enable_diagnostics_for_buffer()
        let b:my_lsp_diagnostics_enabled = 1
        echo "LSP Diagnostics : ON"
    endif
endfunction
command MyToggleLSPDiagnostics call s:MyToggleLSPDiagnostics()
" Toggling diagnostic and virtual text }}}
