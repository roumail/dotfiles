" script-local sink
function! s:rg_scope_sink(choice) abort
  let scope = s:rg_scopes[a:choice]
   " Build arguments array matching the DSL: pattern -- scope
  if s:current_search_pattern ==# '--' || empty(s:current_search_pattern)
    " No pattern, just scope
    call MyRGSearch('--', scope)
  else
    " Pattern with scope
    call MyRGSearch(s:current_search_pattern, '--', scope)
  endif
endfunction

function! RGScopePicker(...) abort
  if !exists('g:project_name')
    echo "No project detected — RGScopePicker disabled"
    return
  endif

  " Validate arguments - only accept 0 or 1 argument
  if a:0 > 1
    echoerr 'RGScopePicker: Too many arguments. Usage: :RGSP [pattern]'
    echoerr 'Did you mean to use :RGS instead? (supports -- separator and options)'
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
