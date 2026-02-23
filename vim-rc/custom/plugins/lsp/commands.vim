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
let g:lsp_diagnostics_default_on = 0  " Set to 1 for ON, 0 for OFF
" ----------------------------------------

function! s:ApplyLSPState(enable, silent)
    if a:enable
        call lsp#enable_diagnostics_for_buffer()
        let b:my_lsp_diagnostics_enabled = 1
        if !a:silent | echo "LSP Diagnostics : ON" | endif
    else
        call lsp#disable_diagnostics_for_buffer()
        let b:my_lsp_diagnostics_enabled = 0
        if !a:silent | echo "LSP Diagnostics : OFF" | endif
    endif
endfunction

" Initialize buffer based on global default
autocmd BufEnter * if !exists('b:my_lsp_diagnostics_enabled') | call s:ApplyLSPState(g:lsp_diagnostics_default_on, 1) | endif

" Toggle function flips the current buffer state
function! s:MyToggleLSPDiagnostics()
    let l:current = get(b:, 'my_lsp_diagnostics_enabled', g:lsp_diagnostics_default_on)
    call s:ApplyLSPState(!l:current, 0)
endfunction

command MyToggleLSPDiagnostics call s:MyToggleLSPDiagnostics()
" Toggling diagnostic and virtual text }}}
