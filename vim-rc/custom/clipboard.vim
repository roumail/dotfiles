" Enable system clipboard access
set clipboard=

" WSL clipboard support (adjust path as needed)
" let s:clip = '/mnt/c/Windows/System32/clip.exe'
" if executable(s:clip)
"   augroup WSLYank
"     autocmd!
"     autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
"   augroup END
" endif


" WSL specific magic since we get extra lines due to \r\n being
" misinterpretted
" if g:is_wsl && executable('win32yank.exe')
"   let g:clipboard = {
"         \ 'name': 'win32yank-wsl',
"         \ 'copy': {
"         \   '+': 'win32yank.exe -i --crlf',
"         \   '*': 'win32yank.exe -i --crlf',
"         \ },
"         \ 'paste': {
"         \   '+': 'win32yank.exe -o --lf',
"         \   '*': 'win32yank.exe -o --lf',
"         \ },
"         \ 'cache_enabled': 0,
"         \ }
" endif

