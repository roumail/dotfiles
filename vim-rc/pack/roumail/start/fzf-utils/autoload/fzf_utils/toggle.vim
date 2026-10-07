" Unified ignore toggle for both rg and fd
" g:fzf_include_ignored:
"   1 = search in ignored files (rg -u, fd -I)
"   0 = respect .gitignore (default)
let s:fzf_include_ignored = get(g:, 'fzf_include_ignored', 0)

function! fzf_utils#toggle#is_ignored_included() abort
  return s:fzf_include_ignored
endfunction

" Update both fd and ripgrep
function! fzf_utils#toggle#toggle_ignored() abort
  let s:fzf_include_ignored = !s:fzf_include_ignored
  call fzf_utils#fd#update_default_fd_command()
  echo 'FZF include ignored: ' . (s:fzf_include_ignored ? 'on' : 'off')
endfunction
