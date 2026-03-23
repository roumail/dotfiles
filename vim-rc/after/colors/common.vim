" --- Canonical diff palette ---
highlight DiffAdd    guibg=#273849 guifg=#C3E88D gui=NONE
highlight DiffDelete guibg=#3a1f2b guifg=#ff5370 gui=NONE
highlight DiffChange guibg=#2f2a44 guifg=#82AAFF gui=NONE
highlight DiffText   guibg=#3e3560 guifg=#ffffff gui=NONE

" --- Syntax diff groups map back to canonical palette ---
highlight! link diffAdded   DiffAdd
" highlight! link diffRemoved DiffDelete
highlight! link diffChanged DiffChange
highlight! link diffText    DiffText
"
" structural diff metadata
highlight! link diffFile       Directory
highlight! link diffIndexLine  Comment

" file headers
highlight! link diffOldFile    DiffDelete
highlight! link diffNewFile    DiffAdd

" hunk headers
highlight! link diffLine       Statement
