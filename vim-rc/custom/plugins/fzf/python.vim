" script-local sink
function! s:rg_scope_sink(choice) abort
  if !has_key(s:rg_scopes, a:choice)
    echo "Invalid choice"
    return
  endif
  let scope = s:rg_scopes[a:choice]
  execute 'MyRG -- ' . scope
endfunction

function! RGScopePicker() abort
  if !exists('g:project_name')
    echo "No project detected — RGScopePicker disabled"
    return
  endif

  let s:rg_scopes = {
  \ 'project': g:project_name . '/',
  \ 'tests': 'tests/',
  \ 'project python': g:project_name . '/ -tpython',
  \ 'tests python': 'tests/ -tpython'
  \ }

  let choice = fzf#run(fzf#wrap({
  \ 'source': keys(s:rg_scopes),
  \ 'sink': function('s:rg_scope_sink')
  \ }))
endfunction
