if exists('b:loaded_md_keymaps_ftplugin')
  finish
endif
let b:loaded_md_keymaps_ftplugin = 1

function! TestSplit()
  call job_start([
        \ 'wezterm', 'cli', 'split-pane', '--right', '--',
        \ 'bash', '-c', 'ls; exec bash'
        \ ],
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
    " execute 'nnoremap <buffer> <localleader>p :silent! !' . s:wezterm_bin . ' cli split-pane --right -- bash -c "echo <C-r>=expand('."'%'".')<CR> \| entr -c glow -t -l /_ ; read"' . "\r"
    nnoremap <buffer> <localleader>p :call TestSplit()<CR>
  endif
endif
