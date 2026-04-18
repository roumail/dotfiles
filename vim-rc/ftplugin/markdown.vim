if exists('b:loaded_md_keymaps_ftplugin')
  finish
endif
let b:loaded_md_keymaps_ftplugin = 1

let maplocalleader = "_"
let s:glow_cmd = ''

function! s:CloseGlowBuffers()
  for b in getbufinfo()
    if b.name =~ 'glow'
      silent execute 'bwipeout!' b.bufnr
    endif
  endfor
endfunction

function! s:GlowPreview()
  call s:CloseGlowBuffers()

  execute 'vert term ' . s:glow_cmd
  setlocal filetype=glow
  file __glow_preview
  " go back to original window
  wincmd p
endfunction

function! s:SetupMarkdownKeymaps() abort
  if !executable('glow')
    return
  endif

  let s:glow_cmd = executable('entr') ? 'sh -c ''echo % | entr -c glow /_''' : 'glow %'
  nnoremap <buffer> <localleader>p :call <SID>GlowPreview()<CR>
endfunction

augroup markdown_glow_keymaps
  autocmd!
  autocmd BufEnter <buffer> call s:SetupMarkdownKeymaps()
augroup END