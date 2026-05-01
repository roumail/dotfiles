if exists('b:loaded_md_keymaps_ftplugin')
  finish
endif
let b:loaded_md_keymaps_ftplugin = 1

function! LiveGlowSplit()
  " unreliable in wsl
  let l:current_pane = $WEZTERM_PANE
  if empty(l:current_pane)
    let l:current_pane = system(s:wezterm_bin . ' cli get-pane-direction Left')
  let l:filename = expand('%:p')

  " 1. Splits the pane and runs entr/glow
  " 2. Uses the captured ID to jump back to Vim
  let l:cmd = printf(
        \ '%s cli split-pane --right -- bash -c "echo %s | entr -c glow -t -l /_" && wezterm cli activate-pane --pane-id %s',
        \ s:wezterm_bin,
        \ l:filename,
        \ l:current_pane
        \ )

  call job_start(['bash', '-c', l:cmd],
        \ {'in_io': 'null', 'out_io': 'null', 'err_io': 'null'})
endfunction

let maplocalleader = "_"
let s:is_wezterm = ($TERM_PROGRAM ==# 'WezTerm' || !empty($WEZTERM_PANE))
let s:is_tmux = !empty($TMUX)

if executable('glow') && executable('entr')
  let s:wezterm_bin = ''
  if executable('wezterm')
    let s:wezterm_bin = 'wezterm'
  elseif executable('wezterm.exe')
    let s:wezterm_bin = 'wezterm.exe'
  endif

  " nnoremap <buffer> <localleader>p :Tmux split-window -d -h 'echo % \| entr -c glow /_'<CR> didn't work because % couldn't be properly expanded
  if s:is_tmux
    nnoremap <buffer> <localleader>p :Tmux split-window -d -h 'echo <C-r>=expand('%')<CR> \\| entr -c glow -t -l /_'<CR>
  " If in wezterm (and not in tmux)
  elseif s:is_wezterm
    nnoremap <buffer> <localleader>p :call LiveGlowSplit()<CR>
  endif
endif
