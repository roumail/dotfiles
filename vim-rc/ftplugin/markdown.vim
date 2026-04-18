if exists('b:loaded_md_keymaps_ftplugin')
  finish
endif
let b:loaded_md_keymaps_ftplugin = 1

let maplocalleader = "_"

function! CloseGlowBuffers()
  for b in getbufinfo()
    if b.name =~ 'glow'
      silent execute 'bwipeout!' b.bufnr
    endif
  endfor
endfunction

function! GlowPreview()
  call CloseGlowBuffers()

  vert term glow %
  setlocal filetype=glow
  file __glow_preview
  " go back to original window
  wincmd p
endfunction

nnoremap <buffer> <localleader>p :call GlowPreview()<CR>
