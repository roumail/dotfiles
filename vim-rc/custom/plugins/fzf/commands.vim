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
    let sep = index(a:arg_list, '--')
    
    " Step 1: Split into pattern and options based on --
    if sep == -1
        " Scenario 3: No '--' found. Assume everything is the pattern.
        let pattern = join(a:arg_list, ' ')
        let options = []
    elseif sep == 0
        " Scenario 2: '--' is the very first token. Empty pattern, only scope.
        let pattern = ''
        let options = a:arg_list[1:]
    else
        " Scenario 1: '--' is in the middle. Pattern before, scope after.
        let pattern = join(a:arg_list[:sep-1], ' ')
        let options = a:arg_list[sep+1:]
    endif
    
    " Step 2: Separate options into paths (trailing /) and rg flags
    let rg_options = []
    
    for item in options
        if item =~ '/$' || item =~ '^\.\{0,2\}/'  " Matches paths ending with / or starting with ./, .., or /
            " Keep original syntax, just add it as a -g "path/**" glob
            call add(rg_options, '-g')
            " Remove trailing slash if present before adding /**
            let path = substitute(item, '/$', '', '')
            call add(rg_options, shellescape(path . '/**'))
        else
            " Keep regular rg flags as-is
            call add(rg_options, item)
        endif
    endfor
    
    return [rg_options, pattern]
endfunction

function! s:rg_command_factory(extra_opts) abort
  " Don't escape - <f-args> already gave us properly parsed arguments
  let l:cmd = s:rg_cmd()
  if !empty(a:extra_opts)
    let l:cmd .= ' ' . join(a:extra_opts, ' ')
  endif
  return l:cmd
endfunction

function! s:rg_mode(prefix, flag) abort
  return a:prefix . (empty(a:flag) ? '' : ' ' . a:flag) . ' -e'
endfunction

function! s:live_grep_handler(bang, preview_options, ...) abort
  let [l:options, l:pattern] = s:parse_live_args(a:000)

  let l:prefix = s:rg_command_factory(l:options)

  let l:cmd_regex = s:rg_mode(l:prefix, '')
  let l:cmd_fixed = s:rg_mode(l:prefix, '-F')
  let l:cmd_word  = s:rg_mode(l:prefix, '-w')


  " \   '--header', ':: C-r (regex) | C-f (fixed) | C-w (word) :: ' . l:prefix,
  let l:extra_opts = {
  \ 'options': [
  \   '--phony', 
  \   '--prompt', 'Regex> ',
  \   '--header', 'C-r (regex) | C-f (fixed) | C-w (word)',
  \   '--bind', 'ctrl-f:change-prompt(Fixed> )+reload(' . l:cmd_fixed . ' {q})',
  \   '--bind', 'ctrl-w:change-prompt(Word> )+reload(' . l:cmd_word  . ' {q})',
  \   '--bind', 'ctrl-r:change-prompt(Regex> )+reload(' . l:cmd_regex . ' {q})',
  \ ]
  \ }
  let l:opts = copy(a:preview_options)
  call extend(l:opts.options, l:extra_opts.options)

  " echom string(l:opts)
  call fzf#vim#grep2(
        \ l:prefix,
        \ l:pattern,
        \ l:opts,
        \ a:bang)
endfunction

" Supports Passing multiple args like directory and glob patterns 
" Rg -u -g "!log/" pat
" \   'window': { 'width': 1.0, 'height': 1.0 }
command! -bang -nargs=* MyRG call s:live_grep_handler(<bang>0, 
      \ fzf#vim#with_preview({
      \   'options': ['--delimiter', ':', '--nth', '4..', '--with-nth', '1,2'],
      \ }, 'right,70%,border-left,+{2}+4/3,~4', 'ctrl-p'), 
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

