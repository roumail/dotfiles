" :Rg is fzf-utils' :RgRaw (raw rg arguments, ignore toggle, query saved to
" :History/) instead of fzf.vim's. Defined at VimEnter: this file is sourced
" before plugins load, so fzf.vim's `command! Rg` would otherwise replace it.
augroup commands_rg_alias
  autocmd!
  autocmd VimEnter * command! -bang -nargs=* Rg RgRaw<bang> <args>
augroup END

" Per-buffer vim-lsp diagnostics toggle (autoload/lsp_diagnostics_toggle.vim)
command! ToggleLspDiagnostics call lsp_diagnostics_toggle#toggle()

" Pick a scope of the current project, then live grep in it (autoload/grepscope.vim)
command! -nargs=? GrepScope call grepscope#run(<f-args>)
