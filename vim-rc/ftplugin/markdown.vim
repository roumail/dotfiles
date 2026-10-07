if exists('b:loaded_md_keymaps_ftplugin')
  finish
endif
let b:loaded_md_keymaps_ftplugin = 1

"autocmd BufRead,BufNewFile *.md,*.txt setlocal wrap " DO wrap on markdown files
setlocal wrap linebreak textwidth=0
" This is done because otherwise vim syntax always wins
" syntax/markdown.vim sources after this file, so defer via BufWinEnter
autocmd BufWinEnter <buffer> ++once setlocal syntax=
setlocal syntax=

" Coming from instant markdown, which uses a browser
":InstantMarkdownPreview to start and :InstantMarkdownStop
let g:instant_markdown_autostart = 0
let maplocalleader = "_"

nmap <buffer> <localleader>p <Plug>(glow-preview)
nmap <buffer> <localleader>P <Plug>(glow-preview-toggle-live)
