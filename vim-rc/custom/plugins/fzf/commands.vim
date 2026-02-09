" Adapt Markers to show Preview 
" https://github.com/junegunn/fzf.vim/blob/master/plugin/fzf.vim#L70
" Usage: :RgRegex <search_term> - searches from project root
command! -bang -nargs=* RgRegex
    \ call fzf#vim#grep(
    \ 'rg --color=always  -- '.shellescape(<q-args>), 1,
    \ fzf#vim#with_preview(), 0)
" Similar to default FZF command, however FZF doesn't give preview
" https://github.com/junegunn/fzf.vim?tab=readme-ov-file#example-customizing-files-command
command! -bang -nargs=* Files
      \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
command! -bang -nargs=* Buffers
      \ call fzf#vim#buffers(fzf#vim#with_preview(), <bang>0)

function! s:rg_regex(args, bang) abort
  let l:argv = split(a:args)
  let l:pattern = remove(l:argv, 0)
  let l:paths = join(map(l:argv, 'shellescape(v:val)'), ' ')

  let l:cmd =
        \ 'rg --color=always -- '
        \ . shellescape(l:pattern)
        \ . (empty(l:paths) ? '' : ' ' . l:paths)

  call fzf#vim#grep(
        \ l:cmd,
        \ 1,
        \ fzf#vim#with_preview(
        \ {'options': ['--delimiter=:', '--nth=4..']}
        \ ), 
        \ a:bang
        \ )
endfunction
command! -nargs=+ -bang FzGrep call s:rg_regex(<q-args>, <bang>0)
