function! s:rg_scope_sink(choice) abort
  let scope = s:rg_scopes[a:choice]

  " Build arguments array matching the DSL: pattern -- scope
  " If pattern is '--' or empty, treat it as an empty list, otherwise wrap it
  let pattern_part = (s:current_search_pattern ==# '--' || empty(s:current_search_pattern))
        \ ? []
        \ : [s:current_search_pattern]

  " Concatenate: [pattern?] + ['--'] + [scopes?]
  let args = pattern_part + ['--'] + scope
  call call('fzf_utils#live_grep#window', args)
endfunction

function! fzf_utils#rg_scope#run(...) abort
  " Validate arguments - only accept 0 or 1 argument
  if a:0 > 1
    echoerr 'RGScopePicker: Too many arguments. Usage: :GrepScope [pattern]'
    echoerr 'Did you mean to use :Grep instead? (supports -- separator and options)'
    return
  endif
  if !exists('g:project_name')
    echo "No project detected — falling back to Grep"
    if a:0 > 0
      call fzf_utils#live_grep#window(a:1)
    else
      call fzf_utils#live_grep#window()
    endif
    return
  endif


  let s:current_search_pattern = a:0 > 0 ? a:1 : '--'

  let s:rg_scopes = {
        \ 'all': [],
        \ 'project': [g:project_name . '/'],
        \ 'tests': ['tests/'],
        \ 'project python': [g:project_name . '/', '-tpy'],
        \ 'tests python': ['tests/', '-tpy']
        \ }
  let s:rg_scope_order = [
        \ 'all',
        \ 'project',
        \ 'project python',
        \ 'tests',
        \ 'tests python'
        \ ]

  let choice = fzf#run(fzf#wrap({
        \ 'source': s:rg_scope_order,
        \ 'sink': function('s:rg_scope_sink')
        \ }))
endfunction
