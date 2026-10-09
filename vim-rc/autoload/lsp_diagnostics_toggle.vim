" Per-buffer toggle for vim-lsp diagnostics (:ToggleLspDiagnostics in
" plugin/commands.vim, <leader>md in after/plugin/keymaps.vim, set up in
" plugin/lsp.vim). Buffers that haven't been toggled follow s:default_on.

" Diagnostics state for buffers that haven't been toggled: 1 = on, 0 = off
let s:default_on = 0

function! s:apply(enable, silent) abort
  if a:enable
    call lsp#enable_diagnostics_for_buffer()
  else
    call lsp#disable_diagnostics_for_buffer()
  endif
  let b:lsp_diagnostics_toggled_on = a:enable
  if !a:silent
    echo 'LSP Diagnostics : ' . (a:enable ? 'ON' : 'OFF')
  endif
endfunction

function! lsp_diagnostics_toggle#apply_default() abort
  if !exists('b:lsp_diagnostics_toggled_on')
    call s:apply(s:default_on, 1)
  endif
endfunction

function! lsp_diagnostics_toggle#toggle() abort
  call s:apply(!get(b:, 'lsp_diagnostics_toggled_on', s:default_on), 0)
endfunction
