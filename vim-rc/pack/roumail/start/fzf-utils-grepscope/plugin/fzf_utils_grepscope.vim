" fzf-utils-grepscope: pick a project scope, then live grep in it.
" Requires junegunn/fzf and fzf-utils-rg (for the live grep itself).
if exists('g:loaded_fzf_utils_grepscope')
  finish
endif
let g:loaded_fzf_utils_grepscope = 1

" GrepScope: Interactive scope picker for grep
"
" Presents a menu to select search scope based on g:project_name:
"   - project: Search in project directory
"   - tests: Search in tests directory
"   - project python: Search Python files in project
"   - tests python: Search Python files in tests
"
" Falls back to :Grep if no project is detected.
"
" Examples:
"   :GrepScope pattern
"   :GrepScope
command! -nargs=* GrepScope call fzf_utils#rg_scope#run(<f-args>)

" g:project_name (from pyproject.toml) drives the GrepScope scopes
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
