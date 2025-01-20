" https://github.com/junegunn/fzf/blob/master/README-VIM.md
let g:fzf_layout = { 'down': '~40%' }
" An action can be a reference to a function that processes selected lines
function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val, "lnum": 1 }'))
  copen
  cc
endfunction

" let g:fzf_action = {
"   \ '<leader>q': function('s:build_quickfix_list'),
"   \ '<leader>t': 'tab split',
"   \ '<leader>x': 'split',
"   \ '<leader>v': 'vsplit' }


" Enable per-command history
" - History files will be stored in the specified directory
" - When set, CTRL-N and CTRL-P will be bound to 'next-history' and
"   'previous-history' instead of 'down' and 'up'.
let g:fzf_history_dir = '~/.local/share/fzf-history'
