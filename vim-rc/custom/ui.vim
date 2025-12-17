" UI and appearance
set number relativenumber
set nohlsearch              " Highlight search results
set showmatch             " Highlight matching parentheses, brackets, and braces
syntax on
filetype plugin indent on
" Set netrw config
let g:netrw_banner = 0
let g:netrw_liststyle = 3
" open in prior window
let g:netrw_browse_split = 4
let g:netrw_list_hide=netrw_gitignore#Hide()
let g:netrw_list_hide.=',\(^\|\s\s\)\zs\.\S\+'
let g:netrw_altv = 1  " Open splits to the right
let g:netrw_winsize = 25

if (has("termguicolors"))
  if &term !=# 'win32'
    set termguicolors
  else
    set notermguicolors
  endif
endif
set background=dark
" xcodedarkhc, xcodehc 
"colorscheme xcodedarkhr
colorscheme palenight
let g:palenight_terminal_italics=1
let g:palenight_color_overrides = {
    \ 'black': { 'gui': '#000000', "cterm": "0", "cterm16": "0" },
    \ 'comment_grey': { 'gui': '#FF8800', 'cterm': '214', 'cterm16': '3' }
      \ }

set splitbelow splitright " Open splits below and to the right


" Vertically center document when entering insert mode
autocmd InsertEnter * norm zz

" Cursor settings
" set cursorline
" set cursorcolumn
" highlight CursorLine ctermbg=LightGrey guibg=#505050  cterm=bold 
" highlight CursorColumn ctermbg=LightGrey guibg=#505050  cterm=bold 


" Change based on mode
let &t_SI = "\e[6 q"      " Vertical bar cursor in Insert mode
let &t_EI = "\e[2 q"      " Block cursor in Normal mode

" Show matching files when we tab complete
set wildmenu