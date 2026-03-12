" Base commands (default respects .gitignore)
let s:rg_base = 'rg --column --line-number --no-heading --color=always --smart-case'

function! s:rg_cmd() abort
  return s:rg_base . (fzf_utils#toggle#is_ignored_included() ? ' -u' : '')
endfunction

function! fzf_utils#ripgrep#get_command() abort
  return s:rg_cmd()
endfunction

function! fzf_utils#ripgrep#command_factory(extra_opts) abort
  " Don't escape - <f-args> already gave us properly parsed arguments
  let l:cmd = s:rg_cmd()
  if !empty(a:extra_opts)
    let l:cmd .= ' ' . join(a:extra_opts, ' ')
  endif
  return l:cmd
endfunction

function! fzf_utils#ripgrep#mode(prefix, flag) abort
  return a:prefix . (empty(a:flag) ? '' : ' ' . a:flag) . ' -e'
endfunction