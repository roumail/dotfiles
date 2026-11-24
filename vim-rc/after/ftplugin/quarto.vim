" .qmd buffers: quarto-slides on _p, _r and _o. In after/ because Vim's quarto
" ftplugin sources the markdown ones, ours included, whose _p is glow's.
setlocal wrap linebreak textwidth=0

if getline(1) ==# '---'
  call search('^---$', 'W')
  call search('^.', 'W')
endif

nmap <buffer> <localleader>p <Plug>(quarto-slides-preview)
nmap <buffer> <localleader>r <Plug>(quarto-slides-render)
nmap <buffer> <localleader>o <Plug>(quarto-slides-open)
