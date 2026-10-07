" Project strategies for :GrepScope (pack/roumail/start/fzf-utils-grepscope).
" Tried in registration order; the first whose detect() returns a name wins.

" Python: the project is named in the nearest pyproject.toml
function! s:pyproject_name() abort
  let l:file = findfile('pyproject.toml', '.;')
  if empty(l:file) || !filereadable(l:file)
    return ''
  endif

  try
    for l:line in readfile(l:file)
      if l:line =~ '^name\s*='
        return matchstr(l:line, '"\zs[^"]\+\ze"')
      endif
    endfor
  catch
  endtry
  return ''
endfunction

function! s:python_scopes(name) abort
  return [
        \ ['project', [a:name . '/']],
        \ ['project python', [a:name . '/', '-tpy']],
        \ ['tests', ['tests/']],
        \ ['tests python', ['tests/', '-tpy']],
        \ ]
endfunction

call fzf_utils#project#register('python', {
      \ 'detect': function('s:pyproject_name'),
      \ 'scopes': function('s:python_scopes'),
      \ })
