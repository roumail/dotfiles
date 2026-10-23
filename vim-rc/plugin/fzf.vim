" https://github.com/junegunn/fzf/blob/master/README-VIM.md
" let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6, 'rounded': v:false ,'yoffset': 1.0 } }
let g:fzf_layout = { 'down': '~40%' }
let g:fzf_commits_log_options = '--graph --color=always
      \ --format="%C(yellow)%h%C(red)%d%C(reset)
      \ - %C(bold green)(%ar)%C(reset) %s %C(blue)<%an>%C(reset)"'

" An action can be a reference to a function that processes selected lines
function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction

let g:fzf_action = {
      \ 'ctrl-q': function('s:build_quickfix_list'),
      \ 'ctrl-t': 'tab split',
      \ 'ctrl-x': 'split',
      \ 'ctrl-v': 'vsplit' }

" Initialize configuration dictionary
let g:fzf_vim = {}
" Avoid matching on file name
let g:fzf_vim.rg_options = '--nth 4..'
" :Commits previews the commit's --stat (e.g. to check a rebase); alt-t
" switches between stat and patch. ctrl-t stays 'tab split' (g:fzf_action).
let s:commit = '$(echo {} | grep -o "[a-f0-9]\{7,\}" | head -1)'
let g:fzf_vim.commits_options = [
      \ '--preview-label', ' stat ',
      \ '--preview', 'case "$FZF_PREVIEW_LABEL" in'
      \   . ' *patch*) git show --color=always --format=format: ' . s:commit
      \   . (executable('delta') ? ' | delta --width $FZF_PREVIEW_COLUMNS' : '') . ';;'
      \   . ' *) git show --stat --color=always --format="%h %s%n" ' . s:commit . ';;'
      \   . ' esac',
      \ '--bind', 'alt-t:transform-preview-label~case "$FZF_PREVIEW_LABEL" in'
      \   . ' *stat*) echo " patch ";; *) echo " stat ";; esac~+refresh-preview',
      \ ]

" Customize fzf colors to match your color scheme
" - fzf#wrap translates this to a set of `--color` options
let g:fzf_colors =
      \ { 'fg':      ['fg', 'Normal'],
      \ 'bg':      ['bg', 'Normal'],
      \ 'query':   ['fg', 'Normal'],
      \ 'hl':      ['fg', 'Comment'],
      \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
      \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
      \ 'hl+':     ['fg', 'Statement'],
      \ 'info':    ['fg', 'PreProc'],
      \ 'border':  ['fg', 'Ignore'],
      \ 'prompt':  ['fg', 'Conditional'],
      \ 'pointer': ['fg', 'Exception'],
      \ 'marker':  ['fg', 'Keyword'],
      \ 'spinner': ['fg', 'Label'],
      \ 'header':  ['fg', 'Comment'] }

" A customized version of fzf#vim#listproc#quickfix.
" The last two lines are commented out not to move to the first entry.
function! g:fzf_vim.listproc(list)
  call setqflist(a:list)
  copen
  wincmd p
  " cfirst
  " normal! zvzz
endfunction

" fzf.vim needs bash to display the preview window.
" On Windows, fzf.vim will first see if bash is in $PATH, then if
" Git bash (C:\Program Files\Git\bin\bash.exe) is available.
" If you want it to use a different bash, set this variable.
"   let g:fzf_vim = {}
"   let g:fzf_vim.preview_bash = 'C:\Git\bin\bash.exe'

" [Tags] Command to generate tags file
" let g:fzf_vim.tags_command = 'ctags -R'

" Enable per-command history
" - History files will be stored in the specified directory
" - When set, CTRL-N and CTRL-P will be bound to 'next-history' and
"   'previous-history' instead of 'down' and 'up'.
" let g:fzf_history_dir = '~/.local/share/fzf-history'
