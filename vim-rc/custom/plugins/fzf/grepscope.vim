" Project detection (roumail/project-detect) and the :GrepScope scopes for each
" project type (roumail/grepscope).

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

" Each registration is skipped until its plugin is installed (before the first
" :PlugInstall on a new machine)
if !empty(globpath(&rtp, 'autoload/project_detect.vim'))
  call project_detect#register('python', {'detect': function('s:pyproject_name')})
endif
if !empty(globpath(&rtp, 'autoload/grepscope.vim'))
  call grepscope#register('python', function('s:python_scopes'))
endif
