if exists('b:loaded_md_keymaps_ftplugin')
  finish
endif
let b:loaded_md_keymaps_ftplugin = 1

let maplocalleader = "_"
" if in tmux ($TMUX)
if executable('glow') && executable('entr')
  let s:wezterm_bin = ''
  if executable('wezterm')
    let s:wezterm_bin = 'wezterm'
  elseif executable('wezterm.exe')
    let s:wezterm_bin = 'wezterm.exe'
  endif
  " nnoremap <buffer> <localleader>p :Tmux split-window -d -h 'echo % \| entr -c glow /_'<CR> didn't work because % couldn't be properly expanded
  if !empty($TMUX)
    nnoremap <buffer> <localleader>p :Tmux split-window -d -h 'echo <C-r>=expand('%')<CR> \\| entr -c glow -t -l /_'<CR>
  " If in wezterm (and not in tmux)
  elseif !empty(s:wezterm_bin)
    execute 'nnoremap <buffer> <localleader>p :silent! !' . s:wezterm_bin . ' cli split-pane --right -- bash -c "echo <C-r>=expand('."'%'".')<CR> \| entr -c glow -t -l /_ ; read"' . "\r"
  endif
endif