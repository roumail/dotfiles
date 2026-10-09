" :GrepScope (plugin/commands.vim): pick a scope of the current project, then
" live grep in it. The scopes come from fzf-utils (fzf_utils#rg#scope#list(),
" built from project-detect). With no project it is a plain :Grep.
function! grepscope#run(...) abort
  let l:pattern = a:0 ? a:1 : ''
  let l:labels = map(fzf_utils#rg#scope#list(), 'v:val[0]')
  if len(l:labels) == 1
    call call('fzf_utils#rg#live_grep#window', a:0 ? [a:1] : [])
    return
  endif
  call fzf#run(fzf#wrap({
        \ 'source': l:labels,
        \ 'sink': {label -> fzf_utils#rg#scope#grep(label, l:pattern)},
        \ }))
endfunction
