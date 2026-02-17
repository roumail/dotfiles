" Adapt Markers to show Preview 
" https://github.com/junegunn/fzf.vim/blob/master/plugin/fzf.vim#L70
" !   RG                *                        call fzf#vim#grep2("rg --column --line-number --no-heading --color=always --smart-case -- ", <q-args>, fzf#vim#with_preview(),
" !   RgRegex           *                        call fzf#vim#grep('rg --color=always  -- '.shellescape(<q-args>), 1, fzf#vim#with_preview(), 0)
" Pass args directly to rg without quoting
" https://github.com/junegunn/fzf.vim/issues/838
" https://github.com/junegunn/fzf.vim/issues/1592
command! -bang -nargs=* Rg call fzf#vim#grep(
            \ "rg --column --line-number --no-heading --color=always --smart-case ".<q-args>,
            \ fzf#vim#with_preview({
            \       'options': '--delimiter : --nth 4.. --preview-window +{2}-5,~3'
            \       }, 'right:50%', 'ctrl-/'),
            \ <bang>0)
" Similar to default FZF command, however FZF doesn't give preview
" https://github.com/junegunn/fzf.vim?tab=readme-ov-file#example-customizing-files-command
command! -bang -nargs=* Files
            \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
command! -bang -nargs=* Buffers
            \ call fzf#vim#buffers(fzf#vim#with_preview(), <bang>0)

