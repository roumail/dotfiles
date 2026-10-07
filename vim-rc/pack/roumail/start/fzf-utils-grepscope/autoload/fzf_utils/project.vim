" Set g:project_name from the nearest pyproject.toml, searching upwards from
" the current directory. GrepScope builds its scopes from it.
function! fzf_utils#project#detect() abort
  " guard
  if exists('g:project_name')
    return
  endif

  let l:file = findfile('pyproject.toml', '.;')
  if empty(l:file) || !filereadable(l:file)
    return
  endif

  try
    for l:line in readfile(l:file)
      if l:line =~ '^name\s*='
        let g:project_name = matchstr(l:line, '"\zs[^"]\+\ze"')
        break
      endif
    endfor
  catch
    return
  endtry
endfunction
