" UI and appearance
syntax on
set termguicolors
set background=dark
" xcodedarkhc, xcodehc 
if filereadable(glob("~/.vim/plugged/vim-colors-xcode/colors/xcode.vim"))
  colorscheme xcodedarkhc
endif

" Vertically center document when entering insert mode
autocmd InsertEnter * norm zz


" Cursor settings
set cursorline
set cursorcolumn
" highlight CursorLine ctermbg=LightGrey cterm=bold guibg=#505050
" highlight CursorColumn ctermbg=LightGrey cterm=bold guibg=#505050

