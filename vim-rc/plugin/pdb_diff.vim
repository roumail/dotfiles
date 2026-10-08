" Terminal-API hook for the `vdiff` command in .config/shell/dots/.pdbrc.py.
" It has to be a global function named Tapi_* (:h terminal-api).

" Called by pdb's `vdiff` from inside a :terminal. Shows expected | actual in
" a single reused tab, so gt/gT flips between the diff and the pdb terminal.
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
