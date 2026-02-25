let s:rg_command = 'rg --column --line-number --no-heading --color=always --smart-case'
" Live Rg (Updates search results as you type in fzf)
command! -bang -nargs=* MyRG call fzf#vim#grep2(
            \ s:rg_command,
            \ <q-args>,
            \ fzf#vim#with_preview({
            \   'options': ['--delimiter', ':', '--nth', '4..']
            \ }, 'up,60%,border-bottom,+{2}+4/3,~4', 'ctrl-p'),
            \ <bang>0)
" TODO: RgRegex, fixed string?
" https://github.com/junegunn/fzf.vim/issues/838
" https://github.com/junegunn/fzf.vim/issues/1592
" Static RG Runs rg once, then fzf filters that fixed list
command! -bang -nargs=* Rg call fzf#vim#grep(
            \ s:rg_command . " " . <q-args>,
            \ fzf#vim#with_preview({
            \       'options': '--delimiter : --nth 4.. --preview-window +{2}-5,~3'
            \       }, 'right:50%', 'ctrl-p'),
            \ <bang>0)
" Similar to default FZF command, however FZF doesn't give preview
" https://github.com/junegunn/fzf.vim?tab=readme-ov-file#example-customizing-files-command
command! -bang -nargs=* Files
            \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
command! -bang -nargs=* Buffers
            \ call fzf#vim#buffers(fzf#vim#with_preview(), <bang>0)

