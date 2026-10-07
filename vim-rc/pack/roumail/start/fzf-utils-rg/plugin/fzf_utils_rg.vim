" fzf-utils-rg: live and static ripgrep through fzf.vim.
" Requires junegunn/fzf.vim and ripgrep. :FzfToggleIgnored comes from fzf-utils.
if exists('g:loaded_fzf_utils_rg')
  finish
endif
let g:loaded_fzf_utils_rg = 1

" Grep: Live grep (updates search results as you type in fzf)
"
" Uses '--' to separate the search pattern from ripgrep options:
"
"   :Grep pattern -- -g "*.vim" -t python
"
" Three scenarios:
"
" 1. Pattern before '--', options after:
"      :Grep error -- -g "*.log"
"    → Initial pattern: "error", filtered to *.log files
"
" 2. No pattern, only options (starts with '--'):
"      :Grep -- -g "*.vim"
"    → No initial pattern, type in fzf, filtered to *.vim files
"
" 3. No '--' found:
"      :Grep error code
"    → Entire input treated as pattern: "error code"
"
" Path shortcuts:
"   Paths ending with '/' or starting with './', '../', or '/'
"   are passed to ripgrep as search paths:
"      :Grep pattern -- src/ ../other/
"
" Mode switching (via keybinds in fzf):
"   C-r: Regex mode (default)
"   C-f: Fixed string mode
"   C-w: Word boundary mode
"
" Bang modifier:
"   :Grep!  → Fullscreen mode
"   :Grep   → Normal mode (windowed)
"
" Examples:
"   :Grep pattern
"   :Grep pattern -- -g "*vim-rc*"
"   :Grep pattern -- -g "!*.log" -t python
"   :Grep -- -g "*.vim"
"   :Grep error -- src/
"   :Grep! pattern  " fullscreen
command! -bang -nargs=* Grep call fzf_utils#live_grep#interactive(<bang>0, <f-args>)

" Rg: Static grep (runs ripgrep once, then fzf filters that fixed list)
"
" Arguments are passed directly to ripgrep as a raw string.
" This allows natural ripgrep syntax such as:
"
"   :Rg pattern
"   :Rg -g "*vim-rc*" pattern
"   :Rg -u -g "!log/" pattern path/to/dir
"
" Unlike Grep, this command does not re-run ripgrep while typing;
" fzf only filters the fixed result set returned by the initial rg run.
"
" Bang modifier:
"   :Rg!  → Fullscreen mode
"   :Rg   → Normal mode (windowed)
" https://github.com/junegunn/fzf.vim/issues/1533#issuecomment-2015075571
command! -bang -nargs=* Rg call fzf#vim#grep(
      \ fzf_utils#ripgrep#get_command() . " " . <q-args>,
      \ fzf_utils#live_grep#capture_query(fzf#vim#with_preview({
      \       'options': '--delimiter : --nth 4.. --preview-window +{2}-5,~3'
      \       }, 'right:50%', 'ctrl-p')),
      \ <bang>0)

" Key mappings; set g:fzf_utils_no_mappings = 1 to define your own instead
if !get(g:, 'fzf_utils_no_mappings', 0)
  nnoremap <silent> <leader>rr <Cmd>call fzf_utils#live_grep#replay()<CR>
  " Fuzzy search scoped to the current buffer's directory
  nnoremap <silent> <leader>r. <Cmd>execute 'Grep -- ' . expand('%:.:h') . '/'<CR>
  " Line search from project root directory
  nnoremap <silent> <leader>r/ <Cmd>Grep<CR>
  " Prefilled to type pattern/scope
  nnoremap <leader>r: :Grep
endif
