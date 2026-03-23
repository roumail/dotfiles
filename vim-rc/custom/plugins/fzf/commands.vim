" Initialize FZF_DEFAULT_COMMAND if not set
if empty($FZF_DEFAULT_COMMAND)
  call fzf_utils#fd#update_default_fd_command()
endif

" Single toggle for both rg and fd
command! FzfToggleIgnored call fzf_utils#toggle#toggle_ignored()

" LiveGrep: Live grep (updates search results as you type in fzf)
"
" Uses '--' to separate the search pattern from ripgrep options:
"
"   :LiveGrep pattern -- -g "*.vim" -t python
"
" Three scenarios:
"
" 1. Pattern before '--', options after:
"      :LiveGrep error -- -g "*.log"
"    → Initial pattern: "error", filtered to *.log files
"
" 2. No pattern, only options (starts with '--'):
"      :LiveGrep -- -g "*.vim"
"    → No initial pattern, type in fzf, filtered to *.vim files
"
" 3. No '--' found:
"      :LiveGrep error code
"    → Entire input treated as pattern: "error code"
"
" Path shortcuts:
"   Paths ending with '/' or starting with './', '../', or '/' 
"   are automatically converted to glob patterns:
"      :LiveGrep pattern -- src/
"    → Becomes: -g "src/**"
"
" Mode switching (via keybinds in fzf):
"   C-r: Regex mode (default)
"   C-f: Fixed string mode
"   C-w: Word boundary mode
"
" Bang modifier:
"   :LiveGrep!  → Fullscreen mode
"   :LiveGrep   → Normal mode (windowed)
"
" Examples:
"   :LiveGrep pattern
"   :LiveGrep pattern -- -g "*vim-rc*"
"   :LiveGrep pattern -- -g "!*.log" -t python
"   :LiveGrep -- -g "*.vim"
"   :LiveGrep error -- src/
"   :LiveGrep! pattern  " fullscreen
command! -bang -nargs=* LiveGrep call fzf_utils#live_grep#interactive(<bang>0, <f-args>)

" Rg: Static grep (runs ripgrep once, then fzf filters that fixed list)
"
" Arguments are passed directly to ripgrep as a raw string.
" This allows natural ripgrep syntax such as:
"
"   :Rg pattern
"   :Rg -g "*vim-rc*" pattern
"   :Rg -u -g "!log/" pattern path/to/dir
"
" Unlike LiveGrep, this command does not re-run ripgrep while typing;
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
