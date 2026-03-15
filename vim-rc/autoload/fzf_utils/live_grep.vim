function! fzf_utils#live_grep#parse_args(arg_list) abort
  let sep = index(a:arg_list, '--')

  " Step 1: Split into pattern and options based on --
  if sep == -1
    " Scenario 3: No '--' found. Assume everything is the pattern.
    let pattern = join(a:arg_list, ' ')
    let options = []
  elseif sep == 0
    " Scenario 2: '--' is the very first token. Empty pattern, only scope.
    let pattern = ''
    let options = a:arg_list[1:]
  else
    " Scenario 1: '--' is in the middle. Pattern before, scope after.
    let pattern = join(a:arg_list[:sep-1], ' ')
    let options = a:arg_list[sep+1:]
  endif

  " Step 2: Separate options into paths (trailing /) and rg flags
  let rg_options = []

  for item in options
    if item =~ '/$' || item =~ '^\.\{0,2\}/'  " Matches paths ending with / or starting with ./, .., or /
        " Keep original syntax, just add it as a -g "path/**" glob
        call add(rg_options, '-g')
      " Remove trailing slash if present before adding /**
      let path = substitute(item, '/$', '', '')
      call add(rg_options, shellescape(path . '/**'))
    else
      " Keep regular rg flags as-is
      call add(rg_options, item)
    endif
  endfor

  return [rg_options, pattern]
endfunction


function! fzf_utils#live_grep#interactive(bang, ...) abort
  let [l:options, l:pattern] = fzf_utils#live_grep#parse_args(a:000)

  let l:prefix = fzf_utils#ripgrep#command_factory(l:options)

  let l:cmd_regex = fzf_utils#ripgrep#mode(l:prefix, '')
  let l:cmd_fixed = fzf_utils#ripgrep#mode(l:prefix, '-F')
  let l:cmd_word  = fzf_utils#ripgrep#mode(l:prefix, '-w')

  let l:preview_opts = fzf#vim#with_preview({
        \ 'options': [
        \   '--delimiter', ':', '--nth', '4..', '--with-nth', '1,2',
        \   '--phony', 
        \   '--prompt', 'Regex> ',
        \   '--header', 'C-r (regex) | C-f (fixed) | C-w (word)',
        \   '--bind', 'ctrl-f:change-prompt(Fixed> )+reload(' . l:cmd_fixed . ' {q})',
        \   '--bind', 'ctrl-w:change-prompt(Word> )+reload(' . l:cmd_word  . ' {q})',
        \   '--bind', 'ctrl-r:change-prompt(Regex> )+reload(' . l:cmd_regex . ' {q})',
        \ ]
        \ }, 'right,70%,border-left,+{2}+4/3,~4', 'ctrl-p')

  call fzf#vim#grep2(l:prefix, l:pattern, l:preview_opts, a:bang)
endfunction

" Convenience wrapper - always fullscreen
function! fzf_utils#live_grep#fullscreen(...) abort
  call call('fzf_utils#live_grep#interactive', [1] + a:000)
endfunction

function! fzf_utils#live_grep#window(...) abort
  call call('fzf_utils#live_grep#interactive', [0] + a:000)
endfunction
