function! SmartFilterClose()
  let l:current = bufnr('%')
  " Define what to ignore
  let l:skip_bt = ['terminal', 'nofile']
  let l:skip_ft = ['netrw']

  " Get all listed buffers
  let l:all_bufs = filter(range(1, bufnr('$')), 'buflisted(v:val)')

  " Filter out based on our skip variables
  let l:valid_bufs = filter(l:all_bufs,
        \ 'index(l:skip_bt, getbufvar(v:val, "&buftype")) == -1 && ' .
        \ 'index(l:skip_ft, getbufvar(v:val, "&filetype")) == -1')

  " Find index and jump.
  " If current is a terminal, idx is -1, so it jumps to the last valid buffer.
  let l:idx = index(l:valid_bufs, l:current)
  let l:target_idx = (l:idx - 1 + len(l:valid_bufs)) % len(l:valid_bufs)

  execute 'buffer ' . l:valid_bufs[l:target_idx]

  " Delete with silent! to ignore Netrw/Terminal complaints
  execute 'silent! bdelete! ' . l:current
endfunction

" Switch to the alternate buffer, skipping netrw listings. If # is a netrw
" buffer (or missing), fall back to the most recently used other buffer.
function! s:is_netrw(nr) abort
  return getbufvar(a:nr, '&filetype') ==# 'netrw'
        \ || !empty(getbufvar(a:nr, 'netrw_curdir'))
        \ || bufname(a:nr) =~# 'NetrwTreeListing'
        \ || isdirectory(bufname(a:nr))
endfunction

function! s:is_alt_candidate(nr) abort
  return a:nr > 0 && a:nr != bufnr('%') && bufexists(a:nr) && !s:is_netrw(a:nr)
endfunction

function! AltBuffer() abort
  let l:target = bufnr('#')
  if !s:is_alt_candidate(l:target)
    let l:bufs = filter(getbufinfo({'buflisted': 1}),
          \ 's:is_alt_candidate(v:val.bufnr)')
    if empty(l:bufs)
      echo 'No alternate buffer'
      return
    endif
    let l:target = sort(l:bufs, {a, b -> b.lastused - a.lastused})[0].bufnr
  endif
  execute 'buffer ' . l:target
endfunction

function! s:list_buffers()
  redir => list
  silent ls
  redir END
  return split(list, "\n")
endfunction

function! s:delete_buffers(lines)
  execute 'bwipeout' join(map(a:lines, {_, line -> split(line)[0]}))
endfunction

command! BD call fzf#run(fzf#wrap({
  \ 'source': s:list_buffers(),
  \ 'sink*': { lines -> s:delete_buffers(lines) },
  \ 'options': '--multi --reverse --bind ctrl-a:select-all+accept'
\ }))

function! s:Scratch(bang)
  if !a:bang
    vsplit
  endif
  noswapfile hide enew
  setlocal buftype=nofile bufhidden=wipe
  let l:idx = 1
  while bufexists('scratch' . l:idx)
    let l:idx += 1
  endwhile
  execute 'file scratch' . l:idx
endfunction

command! -bang Scratch call s:Scratch(<bang>0)

function! s:ScratchFrom(cmd)
  enew
  setlocal buftype=nofile bufhidden=wipe noswapfile
  call setline(1, systemlist(a:cmd))
endfunction

command! -nargs=+ ScratchFrom call s:ScratchFrom(<q-args>)

" Copy a buffer into a new scratch buffer, keeping its filetype.
" No argument or %: current buffer, limited to the range if one is given.
" Otherwise: that whole buffer (name, number or #, <Tab> completes).
function! s:ScratchBuf(bang, line1, line2, buf) abort
  if empty(a:buf) || a:buf ==# '%'
    let l:src = bufnr('%')
    let l:lines = getline(a:line1, a:line2)
  else
    let l:src = a:buf =~# '^\d\+$' ? str2nr(a:buf) : bufnr(a:buf)
    if l:src < 1 || !bufexists(l:src)
      echoerr 'ScratchBuf: no buffer matching ' . a:buf
      return
    endif
    call bufload(l:src)
    let l:lines = getbufline(l:src, 1, '$')
  endif
  let l:ft = getbufvar(l:src, '&filetype')

  call s:Scratch(a:bang)
  call setline(1, l:lines)
  let &l:filetype = l:ft
endfunction

command! -bang -range=% -nargs=? -complete=buffer ScratchBuf
      \ call s:ScratchBuf(<bang>0, <line1>, <line2>, <q-args>)


function! s:ScratchSave(bang, path) abort
  if &buftype !=# 'nofile'
    echoerr 'Not a scratch buffer'
    return
  endif
  let l:path = a:path
  if empty(l:path)
    call mkdir(g:scratch_dir, 'p')
    let l:path = g:scratch_dir . '/' . strftime('%Y%m%d-%H%M%S') . '.txt'
  endif
  execute 'keepalt file' fnameescape(fnamemodify(l:path, ':p'))
  setlocal buftype= bufhidden= swapfile
  execute 'write' . (a:bang ? '!' : '')
  filetype detect
endfunction

command! -bang -nargs=? -complete=file ScratchSave call s:ScratchSave(<bang>0, <q-args>)

" The default lsp behaviour is to open a quickfix/location list
"https://github.com/prabirshrestha/vim-lsp/pull/1140/changes#diff-5644b29c0f34f56ca832ab251585503f273b59b2149cf29c7a38c004c2bad69c
" These overrides attempt to prevent these from happening
function! MyLspQuickfix() abort
  " botright copen
endfunction

function! ToggleQuickfix()
  " Check if any quickfix window is open
  let l:win = filter(range(1, winnr('$')), 'getwinvar(v:val, "&buftype") ==# "quickfix"')
  if empty(l:win)
    copen
  else
    cclose
  endif
endfunction

function! MyLspLocationlist() abort
  " botright lopen
endfunction

let g:Lsp_copen_funcref = function('MyLspQuickfix')
let g:Lsp_lopen_funcref = function('MyLspLocationlist')

function! DetectProjectName() abort
  " guard
  if exists('g:project_name')
    return
  endif

  let l:file = findfile('pyproject.toml', '.;')
  if empty(l:file) || !filereadable(l:file)
    return
  endif

  try
    for l:line in readfile(l:file)
      if l:line =~ '^name\s*='
        let g:project_name = matchstr(l:line, '"\zs[^"]\+\ze"')
        break
      endif
    endfor
  catch
    return
  endtry
endfunction

command! QuickFixToLocList call setloclist(0, getqflist())
command! LocListToQuickFix call setqflist(getloclist(0))

function! s:NextFoldMarkerNumber() abort
  let s:fold_marker_counter += 1
  return s:fold_marker_counter
endfunction

" Numbers {{{ fold markers as {{{ (1/3), {{{ (2/3), ... for easy navigation
function! NumberFoldMarkers() abort
  let l:total = str2nr(matchstr(execute('%s/{{{//gn'), '\d\+'))
  let s:fold_marker_counter = 0
  execute '%s#{{{#\="{{{ (" . s:NextFoldMarkerNumber() . "/" . l:total . ")"#g'
endfunction

" Strips the (n/total) suffix added by NumberFoldMarkers back to plain {{{
function! StripFoldMarkerNumbers() abort
  %s/\({{{\) (\d\+\/\d\+)/\1/g
endfunction

command! NumberFoldMarkers call NumberFoldMarkers()
command! StripFoldMarkerNumbers call StripFoldMarkerNumbers()

" Handle {'foo': True, 'bar': None}
"  This works but not as a function due to escaping
"  :%!python3 -c "import ast,json,sys;obj=ast.literal_eval(sys.stdin.read());print(json.dumps(obj,sort_keys=True,indent=2))"
function! NormalizePythonDict(line1, line2) abort
  let l:script = 'import ast,json,sys;obj=ast.literal_eval(sys.stdin.read());print(json.dumps(obj,sort_keys=True,indent=2,ensure_ascii=False))'
  execute a:line1 . ',' . a:line2 . '!python3 -c ' . shellescape(l:script)
endfunction

" handles '{"foo": true, "bar": null}'
"  This works but not as a function due to escaping
"  :%!python3 -c "import ast,json,sys;s=ast.literal_eval(sys.stdin.read());obj=json.loads(s);print(json.dumps(obj,sort_keys=True,indent=2))"
function! NormalizeJsonString(line1, line2) abort
  let l:script = 'import ast,json,sys;s=ast.literal_eval(sys.stdin.read());obj=json.loads(s);print(json.dumps(obj,sort_keys=True,indent=2,ensure_ascii=False))'
  execute a:line1 . ',' . a:line2 . '!python3 -c ' . shellescape(l:script)
endfunction

command! -range=% NormalizeJsonString call NormalizeJsonString(<line1>, <line2>)
command! -range=% NormalizePythonDict call NormalizePythonDict(<line1>, <line2>)

" Reduce pytest output (or coverage test contexts) in the current buffer to
" one line per test, grouped into blank-line separated blocks.
"
"   :ParsePytestFailures    one block per file
"   :ParsePytestFailures!   one block per test class (module-level tests of a
"                           file form their own block)
"
" Blocks with fewer lines are moved towards the top (ties keep alphabetical
" order).
function! ParsePytestFailures(...) abort
  let l:by_class = a:0 ? a:1 : 0

  " Pytest output: keep only FAILED / ERROR lines, ignoring anything before
  " them (whitespace, timestamps, [gw0] ...). The lookahead requires a *.py
  " path after the marker, so log lines like "ERROR: boom" are not picked up.
  " Skipped for pasted coverage contexts, which have no such lines and would
  " otherwise all be deleted.
  let l:marker = '^.\{-}\<\%(FAILED\|ERROR\)\s\+\ze\S\+\.py'
  if search(l:marker, 'nw')
    execute 'g!/' . l:marker . '/d'
    " Remove everything up to and including the FAILED/ERROR prefix
    execute '%s/' . l:marker . '//e'
    " Remove the trailing error message (pytest separates it with ' - ')
    %s/\s-.*$//e
  endif

  " Remove coverage context phase, e.g. test_foo[a-1]|run -> test_foo[a-1]
  %s/|\(run\|setup\|teardown\)$//e

  " Remove parametrization ids, e.g. test_foo[a-1] -> test_foo
  %s/\[.*\]$//e

  " Sort and remove duplicates
  sort u

  call s:GroupPytestBlocks(l:by_class)
endfunction

" Split the (sorted, unique) buffer lines into blocks keyed by file, or by
" file::Class when by_class is set, sort the blocks by line count (smallest
" first) and write them back separated by an empty line.
function! s:GroupPytestBlocks(by_class) abort
  let l:order = []
  let l:groups = {}
  for l:line in getline(1, '$')
    if empty(l:line)
      continue
    endif
    let l:parts = split(l:line, '::')
    if empty(l:parts)
      let l:key = l:line
    elseif a:by_class && len(l:parts) > 1
      " everything but the test name: file or file::Class[::Nested]
      let l:key = join(l:parts[0 : -2], '::')
    else
      let l:key = l:parts[0]
    endif
    if !has_key(l:groups, l:key)
      let l:groups[l:key] = []
      call add(l:order, l:key)
    endif
    call add(l:groups[l:key], l:line)
  endfor

  " sort() is stable, so equally sized blocks keep their alphabetical order
  let l:blocks = map(copy(l:order), {_, k -> l:groups[k]})
  call sort(l:blocks, {a, b -> len(a) - len(b)})

  let l:out = []
  for l:block in l:blocks
    if !empty(l:out)
      call add(l:out, '')
    endif
    call extend(l:out, l:block)
  endfor

  silent %delete _
  call setline(1, l:out)
endfunction

command! -bang ParsePytestFailures call ParsePytestFailures(<bang>0)

" Called by pdb's `vdiff` (.pdbrc.py) from inside a :terminal via the terminal
" API (:h terminal-api). Shows expected | actual in a single reused tab, so
" gt/gT flips between the diff and the pdb terminal.
function! Tapi_PdbDiff(bufnr, files) abort
  let l:tab = 0
  for l:t in range(1, tabpagenr('$'))
    if gettabvar(l:t, 'pdb_diff', 0)
      let l:tab = l:t
      break
    endif
  endfor
  if l:tab
    execute l:tab . 'tabnext'
    diffoff!
    silent! only!
  else
    tabnew
    let t:pdb_diff = 1
  endif
  execute 'edit!' fnameescape(a:files[0])
  setlocal bufhidden=wipe
  execute 'rightbelow vertical diffsplit' fnameescape(a:files[1])
  setlocal bufhidden=wipe
endfunction
