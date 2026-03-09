" script-local sink
function! s:rg_scope_sink(choice) abort
  let scope = s:rg_scopes[a:choice]
  execute 'MyRG! ' . s:current_search_pattern . ' ' . scope
endfunction

function! RGScopePicker(pattern = '--') abort
  if !exists('g:project_name')
    echo "No project detected — RGScopePicker disabled"
    return
  endif

  let s:current_search_pattern = a:pattern

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
