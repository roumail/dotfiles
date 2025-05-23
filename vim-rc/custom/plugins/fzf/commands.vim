command! -bang -nargs=* RgIn call fzf#vim#grep(
  \ printf('rg --column --line-number --no-heading --color=always --smart-case %s', <q-args>), 1,
  \ fzf#vim#with_preview({'options': ['--delimiter=:', '--nth=4..']}),
  \ <bang>0)
command! -bang -nargs=* Files
      \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
command! -bang -nargs=* Buffers
      \ call fzf#vim#buffers(fzf#vim#with_preview(), <bang>0)
