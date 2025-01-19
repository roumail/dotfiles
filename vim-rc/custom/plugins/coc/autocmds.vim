" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

augroup mygroup
  autocmd!
  " Update
  " Setup formatexpr specified filetype(s)
  " autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Docker compose 
au FileType yaml if bufname("%") =~# "docker-compose.yml" | set ft=yaml.docker-compose | endif
au FileType yaml if bufname("%") =~# "compose.yml" | set ft=yaml.docker-compose | endif

let g:coc_filetype_map = {
  \ 'yaml.docker-compose': 'dockercompose',
  \ }
