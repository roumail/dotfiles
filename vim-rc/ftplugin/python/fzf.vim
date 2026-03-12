if exists('b:loaded_python_fzf_ftplugin')
  finish
endif
let b:loaded_python_fzf_ftplugin = 1

function! s:rg_scope_sink(choice) abort
  let scope = s:rg_scopes[a:choice]
   " Build arguments array matching the DSL: pattern -- scope
  if s:current_search_pattern ==# '--' || empty(s:current_search_pattern)
    " No pattern, just scope
    call LiveGrepSearch('--', scope)
  else
    " Pattern with scope
    call LiveGrepSearch(s:current_search_pattern, '--', scope)
  endif
endfunction

function! RGScopePicker(...) abort
  " Validate arguments - only accept 0 or 1 argument
  if a:0 > 1
    echoerr 'RGScopePicker: Too many arguments. Usage: :GrepScope [pattern]'
    echoerr 'Did you mean to use :Grep instead? (supports -- separator and options)'
    return
  endif
  if !exists('g:project_name')
    echo "No project detected — falling back to LiveGrep"
    if a:0 > 0
      call LiveGrepSearch(a:1)
    else
      call LiveGrepSearch()
    endif
    return
  endif


  let s:current_search_pattern = a:0 > 0 ? a:1 : '--'

  let s:rg_scopes = {
  \ 'project': g:project_name . '/',
  \ 'tests': 'tests/',
  \ 'project python': g:project_name . '/ -tpy',
  \ 'tests python': 'tests/ -tpy'
  \ }

  let choice = fzf#run(fzf#wrap({
  \ 'source': keys(s:rg_scopes),
  \ 'sink': function('s:rg_scope_sink')
  \ }))
endfunction
