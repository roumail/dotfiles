if exists('b:loaded_md_keymaps_ftplugin')
  finish
endif
let b:loaded_md_keymaps_ftplugin = 1

let maplocalleader = "_"
let s:is_wezterm = ($TERM_PROGRAM ==# 'WezTerm' || !empty($WEZTERM_PANE))
let s:is_tmux = !empty($TMUX)

" Default mode
let g:markdown_glow_live_preview = v:false

" ---------------------------------------------------------------------
" Glow preview mode toggle
" ---------------------------------------------------------------------

function! s:ToggleGlowPreviewMode() abort
  let g:markdown_glow_live_preview = !g:markdown_glow_live_preview

  if g:markdown_glow_live_preview
    echo "Glow preview: LIVE"
  else
    echo "Glow preview: STATIC"
  endif
endfunction

" ---------------------------------------------------------------------
" Static preview
" ---------------------------------------------------------------------

function! s:CloseGlowBuffers() abort
  for b in getbufinfo()
    if b.name =~# '__glow_preview'
      silent execute 'bwipeout!' b.bufnr
    endif
  endfor
endfunction

function! s:GlowStaticPreview() abort
  call s:CloseGlowBuffers()

  execute 'vert term glow %'
  setlocal filetype=glow
  file __glow_preview

  " jump back
  wincmd p
endfunction

" ---------------------------------------------------------------------
" Live preview (wezterm)
" ---------------------------------------------------------------------
function! s:GlowLivePreviewWezterm() abort
  let l:filename = shellescape(expand('%:p'))
  " It isn't easy to switch back to the original pane back again in wezterm on
  " wsl
  let l:cmd = printf(
        \ '%s cli split-pane --right -- bash -c "echo %s | entr -c glow -t -l /_"',
        \ s:wezterm_bin,
        \ l:filename
        \ )

  call job_start(
        \ ['bash', '-c', l:cmd],
        \ {'in_io': 'null', 'out_io': 'null', 'err_io': 'null'}
        \ )
endfunction

" ---------------------------------------------------------------------
" Live preview (tmux)
" ---------------------------------------------------------------------

function! s:GlowLivePreviewTmux() abort
  "nnoremap <buffer> <localleader>p :Tmux split-window -d -h 'echo <C-r>=expand('%')<CR> \\| entr -c glow -t -l /_'<CR>
  execute printf(
        \ "Tmux split-window -d -h 'echo %s | entr -c glow -t -l /_'",
        \ shellescape(expand('%:p'))
        \ )
endfunction

" ---------------------------------------------------------------------
" Dispatcher
" ---------------------------------------------------------------------
function! s:GlowPreview() abort
  if g:markdown_glow_live_preview

    if s:is_tmux
      call s:GlowLivePreviewTmux()
      return
    endif

    if s:is_wezterm
      call s:GlowLivePreviewWezterm()
      return
    endif
  endif

  " fallback/default
  call s:GlowStaticPreview()
endfunction

" ---------------------------------------------------------------------
" Setup
" ---------------------------------------------------------------------

function! s:SetupMarkdownKeymaps() abort
  nnoremap <buffer> <localleader>p :call <SID>GlowPreview()<CR>
  nnoremap <buffer> <localleader>P :call <SID>ToggleGlowPreviewMode()<CR>
endfunction

if executable('glow') && executable('entr')
  let s:wezterm_bin = ''

  if executable('wezterm')
    let s:wezterm_bin = 'wezterm'
  elseif executable('wezterm.exe')
    let s:wezterm_bin = 'wezterm.exe'
  endif

  call s:SetupMarkdownKeymaps()
endif
