" Unified ignore toggle for both rg and fd
" g:fzf_include_ignored:
"   1 = search in ignored files (rg -u, fd -I)
"   0 = respect .gitignore (default)
let s:fzf_include_ignored = get(g:, 'fzf_include_ignored', 0)

" Base commands (default respects .gitignore)
let s:rg_base = 'rg --column --line-number --no-heading --color=always --smart-case'
let s:fd_base = 'fd --type f --strip-cwd-prefix --hidden --follow --exclude .git -E "**/__pycache__/**"'

function! s:rg_cmd() abort
  return s:rg_base . (s:fzf_include_ignored ? ' -u' : '')
endfunction

function! s:fd_cmd() abort
  let l:cmd = s:fd_base
  if s:fzf_include_ignored
    " -I = don't respect ignore files, -E still allows explicit excludes
    let l:cmd .= ' -I'
  endif
  return l:cmd
endfunction

function! s:update_fzf_default_command() abort
  let $FZF_DEFAULT_COMMAND = s:fd_cmd()
endfunction

if empty($FZF_DEFAULT_COMMAND)
  call s:update_fzf_default_command()
endif

" Toggle both rg and fd ignore settings
command! FzfToggleIgnored 
      \ let s:fzf_include_ignored = !s:fzf_include_ignored |
      \ call s:update_fzf_default_command() |
      \ echo 'FZF include ignored: ' . (s:fzf_include_ignored ? 'on' : 'off')

function! s:parse_live_args(arg_list) abort
  let l:pattern = get(a:arg_list, 0, '')
  let l:extra = len(a:arg_list) > 1 ? a:arg_list[1:] : []

  " Don't escape - <f-args> already gave us properly parsed arguments
  let l:base_cmd = s:rg_cmd()
  if !empty(l:extra)
      let l:base_cmd .= ' ' . join(l:extra, ' ')
  endif
  
  " Append -e so the live query from FZF is always the pattern
  let l:base_cmd .= ' -e'

  return [l:base_cmd, l:pattern]
endfunction

function! s:live_grep_handler(bang, preview_options, ...) abort
  " a:000 is the internal Vim list of all arguments after preview_options
  let [l:base_cmd, l:pattern] = s:parse_live_args(a:000)
  
  call fzf#vim#grep2(
        \ l:base_cmd,
        \ l:pattern,
        \ a:preview_options,
        \ a:bang)
endfunction

" Supports Passing multiple args like directory and glob patterns 
" Rg -u -g "!log/" pat
command! -bang -nargs=* MyRG call s:live_grep_handler(<bang>0, 
      \ fzf#vim#with_preview({
      \   'options': ['--delimiter', ':', '--nth', '4..']
      \ }, 'up,60%,border-bottom,+{2}+4/3,~4', 'ctrl-p'), 
      \ <f-args>)

" Rg: Static grep (runs ripgrep once, then fzf filters that fixed list)
" Supports passing ripgrep flags, glob patterns, and directories
" Examples:
"   :Rg pattern
"   :Rg -g "*vim-rc*" pattern
"   :Rg -u -g "!log/" pattern path/to/dir
" Static RG Runs rg once, then fzf filters that fixed list
" Supports Passing multiple args like directory and glob patterns 
" Rg -u -g "!log/" pat
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

