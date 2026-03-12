let s:fd_base = 'fd --type f --strip-cwd-prefix --hidden --follow --exclude .git -E "**/__pycache__/**"'

" let s:fzf_include_ignored = get(g:, 'fzf_include_ignored', 0)
function! s:fd_cmd() abort
  let l:cmd = s:fd_base
  if fzf_utils#toggle#is_ignored_included()
    " -I = don't respect ignore files, -E still allows explicit excludes
    let l:cmd .= ' -I'
  endif
  return l:cmd
endfunction

function! fzf_utils#fd#update_default_fd_command() abort
  let $FZF_DEFAULT_COMMAND = s:fd_cmd()
endfunction

