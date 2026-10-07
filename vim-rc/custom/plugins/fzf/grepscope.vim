" Project detection (roumail/project-detect) and the :GrepScope scopes for each
" project type (roumail/fzf-utils-grepscope).

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

" Each registration is skipped until its plugin is installed (e.g. before the
" first :PlugInstall)
if !empty(globpath(&rtp, 'autoload/project_detect.vim'))
  call project_detect#register('python', {'detect': function('s:pyproject_name')})
endif
" Check for the function itself: before :PlugUpdate, an older fzf-utils-rg can
" still provide an autoload/fzf_utils/rg_scope.vim without it
runtime autoload/fzf_utils/rg_scope.vim
if exists('*fzf_utils#rg_scope#register')
  call fzf_utils#rg_scope#register('python', function('s:python_scopes'))
endif
