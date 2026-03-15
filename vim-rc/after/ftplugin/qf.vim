if exists("b:did_qf_ftplugin")
  finish
endif
let b:did_qf_ftplugin = 1

function! s:DeleteQFItem()
  let lnum = line('.')
  let qf = getqflist()

  call remove(qf, lnum - 1)
  call setqflist(qf, 'r')

  call cursor(min([lnum, len(qf)]), 1)
endfunction

nnoremap <buffer> <silent> dd :call <SID>DeleteQFItem()<CR>
nnoremap <buffer> <silent> u  :colder<CR>
