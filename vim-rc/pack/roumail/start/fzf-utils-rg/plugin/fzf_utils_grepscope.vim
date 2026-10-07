" fzf-utils-rg: pick a project scope, then live grep in it with :Grep.
" Requires junegunn/fzf; :Grep is in plugin/fzf_utils_rg.vim.
if exists('g:loaded_fzf_utils_grepscope')
  finish
endif
let g:loaded_fzf_utils_grepscope = 1

" GrepScope: Interactive scope picker for grep
"
" Presents a menu of search scopes: 'all', plus the scopes of the detected
" project. Which projects exist and what scopes they offer comes from the
" strategies registered with fzf_utils#project#register(); none ship here.
"
" Falls back to :Grep if no project is detected.
"
" Examples:
"   :GrepScope pattern
"   :GrepScope
command! -nargs=* GrepScope call fzf_utils#rg_scope#run(<f-args>)

" Run the registered project strategies once everything is loaded
augroup fzf_utils_project
  autocmd!
  autocmd VimEnter * call fzf_utils#project#detect()
augroup END

" Key mappings; set g:fzf_utils_no_mappings = 1 to define your own instead
if !get(g:, 'fzf_utils_no_mappings', 0)
  " Scoped searches (Standard)
  nnoremap <leader>rs <Cmd>GrepScope<CR>
  " Search for word under cursor
  " Word with boundaries
  nnoremap <silent> <leader>rw <Cmd>execute 'GrepScope' '\b' . expand('<cword>') . '\b'<CR>
  " Word without boundaries
  " nnoremap <silent> <leader>rW <Cmd>execute 'GrepScope' expand('<cword>')<CR>
  xnoremap <silent> <leader>rw y:<C-u>execute 'GrepScope' '\b' . getreg('"') . '\b'<CR>
  " xnoremap <silent> <leader>rW y:<C-u>execute 'GrepScope' getreg('"')<CR>
endif
