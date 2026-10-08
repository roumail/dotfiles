" Per-buffer toggle for vim-lsp diagnostics (:ToggleLspDiagnostics, <leader>md
" in keymaps.vim). Buffers that haven't been toggled follow s:default_on.

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

function! s:apply_default() abort
  if !exists('b:lsp_diagnostics_toggled_on')
    call s:apply(s:default_on, 1)
  endif
endfunction

function! s:toggle() abort
  call s:apply(!get(b:, 'lsp_diagnostics_toggled_on', s:default_on), 0)
endfunction

" Set up once plugins have loaded, and only if vim-lsp is installed
function! s:init() abort
  if !exists('g:lsp_loaded')
    return
  endif
  augroup lsp_diagnostics_toggle
    autocmd!
    autocmd BufEnter * call s:apply_default()
  augroup END
  " The current buffer was entered before this ran
  call s:apply_default()

  command! ToggleLspDiagnostics call s:toggle()
endfunction

augroup lsp_diagnostics_toggle_init
  autocmd!
  autocmd VimEnter * ++once call s:init()
augroup END
