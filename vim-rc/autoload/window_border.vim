" Move a window border in a fixed direction, whichever window you are in
" (<C-w> > < + - in after/plugin/keymaps.vim). The built-in keys grow or
" shrink the current window, so the border moves the other way from the
" rightmost window. With no neighbour on that side, the border on the
" opposite side is the one that moves.

" Columns/lines per press; a count sets it instead
let s:step = 5

let s:keys = {'r': ">", 'l': "<", 'd': "+", 'u': "-"}

" dir: 'l' or 'r' (vertical border), 'u' or 'd' (horizontal border)
function! window_border#move(dir) abort
  let l:step = v:count ? v:count : s:step
  if a:dir =~# '[lr]'
    let l:grow = (a:dir ==# 'r') == (winnr('l') != winnr())
    execute 'vertical resize ' . (winwidth(0) + (l:grow ? l:step : -l:step))
  else
    let l:grow = (a:dir ==# 'd') == (winnr('j') != winnr())
    execute 'resize ' . (winheight(0) + (l:grow ? l:step : -l:step))
  endif
  silent! call repeat#set("\<C-w>" . s:keys[a:dir], v:count)
endfunction
