if exists("b:did_qf_ftplugin")
  finish
endif
let b:did_qf_ftplugin = 1

" dd removes the entry under the cursor, u puts it back (qf-tools)
nmap <buffer> dd <Plug>(qf-tools-delete)
nmap <buffer> u <Plug>(qf-tools-undo)
