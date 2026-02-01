" Adapt Markers to show Preview 
" https://github.com/junegunn/fzf.vim/blob/master/plugin/fzf.vim#L70
" Usage: :RgRegex <search_term> - searches from project root
command! -bang -nargs=* RgRegex
    \ call fzf#vim#grep(
    \ 'rg --color=always  -- '.shellescape(<q-args>), 1,
    \ fzf#vim#with_preview(), 0)
command! -bang -nargs=* Files
      \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
command! -bang -nargs=* Buffers
      \ call fzf#vim#buffers(fzf#vim#with_preview(), <bang>0)
