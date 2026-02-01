" Live Ripgrep in Sibling Directory (Search text in current folder only)
function! LiveSiblingSearch()
  let l:dir = expand('%:p:h')
  call fzf#vim#grep(
    \ 'rg --color=always -- "" '.shellescape(l:dir), 
    \ 1, 
    \ fzf#vim#with_preview(
    \ {'options': ['--delimiter=:', '--nth=4..']}
    \ ), 
    \ 0)
endfunction

function! s:find_git_root()
  return system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
endfunction

function! LiveProjectSearch()
  let l:root = s:find_git_root()

  call fzf#vim#grep(
    \ 'rg -- "" ' . shellescape(l:root),
    \ 1,
    \ fzf#vim#with_preview({
    \   'options': [
    \     '--delimiter=:',
    \     '--nth=4..',
    \     '--with-nth=4..',
    \   ]
    \ }),
    \ 0
    \ )
endfunction
