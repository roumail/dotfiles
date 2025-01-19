" UI and appearance
syntax on
" https://github.com/vim-python/python-syntax?tab=readme-ov-file
let g:python_highlight_all = 1

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

" Change based on mode
let &t_SI = "\e[6 q"      " Vertical bar cursor in Insert mode
let &t_EI = "\e[2 q"      " Block cursor in Normal mode