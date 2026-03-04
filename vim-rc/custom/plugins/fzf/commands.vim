" g:rg_include_ignored:
"   1 = pass -u (search in ignored files)
"   0 = respect .gitignore
let s:rg_base = 'rg --column --line-number --no-heading --color=always --smart-case'
let s:rg_include_ignored = get(g:, 'rg_include_ignored', 0)

function! s:rg_cmd() abort
  return s:rg_base . (s:rg_include_ignored ? ' -u' : '')
endfunction
let s:rg_command = 'rg --column --line-number --no-heading --color=always --smart-case'

command! RgToggleIgnored let s:rg_include_ignored = !s:rg_include_ignored
      \ | echo 'rg include ignored: ' . (s:rg_include_ignored ? 'on' : 'off')

" Live Rg (Updates search results as you type in fzf)
command! -bang -nargs=* MyRG call fzf#vim#grep2(
            \ s:rg_cmd(),
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
            \ s:rg_cmd() . " " . <q-args>,
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

