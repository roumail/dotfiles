if exists('b:loaded_md_keymaps_ftplugin')
  finish
endif
let b:loaded_md_keymaps_ftplugin = 1

let maplocalleader = "_"
if executable('glow') && executable('entr')
  nnoremap <buffer> <localleader>p :Dispatch sh -c 'echo % \| entr -c glow /_'<CR>
elseif executable('glow')
  nnoremap <buffer> <localleader>p :Dispatch glow %<CR>
endif
