" Initialize FZF_DEFAULT_COMMAND if not set
if empty($FZF_DEFAULT_COMMAND)
  call fzf_utils#fd#update_default_fd_command()
endif

" Single toggle for both rg and fd
command! FzfToggleIgnored call fzf_utils#toggle#toggle_ignored()

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
"   are automatically converted to glob patterns:
"      :Grep pattern -- src/
"    → Becomes: -g "src/**"
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
command! -bang -nargs=* Rg call fzf#vim#grep(
      \ fzf_utils#ripgrep#get_command() . " " . <q-args>,
      \ fzf#vim#with_preview({
      \       'options': '--delimiter : --nth 4.. --preview-window +{2}-5,~3'
      \       }, 'right:50%', 'ctrl-p'),
      \ <bang>0)

" Similar to default FZF command, however FZF doesn't give preview
" https://github.com/junegunn/fzf.vim?tab=readme-ov-file#example-customizing-files-command
command! -bang -nargs=* Files
      \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
command! -bang -nargs=* Buffers
      \ call fzf#vim#buffers(fzf#vim#with_preview(), <bang>0)

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
