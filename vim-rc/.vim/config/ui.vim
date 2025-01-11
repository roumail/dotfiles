" UI and appearance
syntax on
if (has("termguicolors"))
  set termguicolors
endif
set background=dark
" xcodedarkhc, xcodehc 
"colorscheme xcodedarkhc
colorscheme palenight

" Vertically center document when entering insert mode
autocmd InsertEnter * norm zz

" Cursor settings
set cursorline
set cursorcolumn
highlight CursorLine ctermbg=LightGrey guibg=#505050  cterm=bold 
highlight CursorColumn ctermbg=LightGrey guibg=#505050  cterm=bold 

" Setting the line length to 80
match ErrorMsg '\%>80v.\+'