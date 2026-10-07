if exists("b:did_qf_ftplugin")
  finish
endif
let b:did_qf_ftplugin = 1

" dd removes the entry under the cursor and u puts it back, in both quickfix
" and location list windows. Once nothing is left to restore in the current
" list, u goes to the older list (:colder / :lolder).

function! s:IsLoclist() abort
  return getwininfo(win_getid())[0].loclist
endfunction

function! s:GetList(what) abort
  return s:IsLoclist() ? getloclist(0, a:what) : getqflist(a:what)
endfunction

" Replaces the items in place, so deleting doesn't use up the 10-list stack
function! s:SetItems(items) abort
  if s:IsLoclist()
    call setloclist(0, [], 'r', {'items': a:items})
  else
    call setqflist([], 'r', {'items': a:items})
  endif
endfunction

" Deleted [lnum, item] pairs, newest last. Reset when the window shows a
" different list.
function! s:UndoStack() abort
  let l:id = s:GetList({'id': 0}).id
  if get(w:, 'qf_undo_id', -1) != l:id
    let w:qf_undo_id = l:id
    let w:qf_undo = []
  endif
  return w:qf_undo
endfunction

function! s:DeleteItem() abort
  let l:items = s:GetList({'items': 1}).items
  if empty(l:items)
    return
  endif
  let l:lnum = line('.')
  call add(s:UndoStack(), [l:lnum, remove(l:items, l:lnum - 1)])
  call s:SetItems(l:items)
  call cursor(min([l:lnum, len(l:items)]), 1)
endfunction

function! s:Undo() abort
  let l:stack = s:UndoStack()
  if empty(l:stack)
    execute s:IsLoclist() ? 'lolder' : 'colder'
    return
  endif
  let [l:lnum, l:item] = remove(l:stack, -1)
  let l:items = s:GetList({'items': 1}).items
  call s:SetItems(insert(l:items, l:item, l:lnum - 1))
  call cursor(l:lnum, 1)
endfunction

nnoremap <buffer> <silent> dd <Cmd>call <SID>DeleteItem()<CR>
nnoremap <buffer> <silent> u  <Cmd>call <SID>Undo()<CR>
