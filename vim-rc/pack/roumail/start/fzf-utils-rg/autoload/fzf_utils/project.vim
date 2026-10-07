" Project strategies for :GrepScope.
"
" A strategy is a dict with two Funcrefs:
"   detect()      -> the project name, or '' when this is not such a project
"   scopes(name)  -> ordered list of [label, rg-args] pairs to offer
"
" Strategies are tried in registration order and the first match wins.
let s:strategies = {}
let s:order = []
let s:active = ''

function! fzf_utils#project#register(name, strategy) abort
  if !has_key(s:strategies, a:name)
    call add(s:order, a:name)
  endif
  let s:strategies[a:name] = a:strategy
  " Registered after startup: detection has already run, so try again
  if v:vim_did_enter && empty(s:active)
    call fzf_utils#project#detect()
  endif
endfunction

" Names of the registered strategies, in detection order
function! fzf_utils#project#strategies() abort
  return copy(s:order)
endfunction

" Name of the strategy that matched, or ''
function! fzf_utils#project#active() abort
  return s:active
endfunction

" Sets g:project_name from the first matching strategy. A g:project_name that
" is already set is kept, so it can be overridden per project.
function! fzf_utils#project#detect() abort
  for l:key in s:order
    let l:name = s:strategies[l:key].detect()
    if !empty(l:name)
      let s:active = l:key
      let g:project_name = get(g:, 'project_name', l:name)
      return
    endif
  endfor
endfunction

" [label, rg-args] pairs of the detected project; empty when there is none
function! fzf_utils#project#scopes() abort
  if empty(s:active) || !exists('g:project_name')
    return []
  endif
  return s:strategies[s:active].scopes(g:project_name)
endfunction
