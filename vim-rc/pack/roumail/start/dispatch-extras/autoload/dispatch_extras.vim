" Prefer vim terminal for interactive processes
" 1 = Launch in terminal
" 0 = Launch in tmux window
function! dispatch_extras#toggle_start_strategy() abort
  let g:dispatch_no_tmux_start = !get(g:, 'dispatch_no_tmux_start', 1)
  echo 'Default Start startegy set to terminal: ' . (g:dispatch_no_tmux_start ? 'on' : 'off')
endfunction

" Repeat the last dispatch command
function! dispatch_extras#repeat_last_start() abort
  if !exists('g:dispatch_last_start')
    echo "No previous dispatch command to repeat"
    return
  endif

  let last = g:dispatch_last_start
  let command = get(last, 'expanded', '')

  if empty(command)
    echo "Could not find command in dispatch history"
    return
  endif

  " Re-run the command using the same handler and options
  let opts = {
        \ 'background': get(last, 'background', 1),
        \ 'directory': get(last, 'directory', getcwd()),
        \ 'handler': get(last, 'handler', 'terminal')
        \ }

  call dispatch#start(command, opts)
endfunction
