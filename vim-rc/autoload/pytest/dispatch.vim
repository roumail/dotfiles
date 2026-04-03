" Helper function to run pytest with trace in terminal
function! pytest#dispatch#WithScopeAndTrace(scope, bang) abort
  let test_path = pytest#common#GetTestPath(a:scope)

  if empty(test_path)
    echo "Could not determine test path for scope: " . a:scope
    return
  endif

  let debug_flag = empty(a:bang) ? '--trace' : '--pdb'
  execute 'Start! -strategy=terminal pytest ' . test_path . ' ' . debug_flag
endfunction

" Repeat the last dispatch command
function! pytest#dispatch#RepeatLast() abort
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
" -- needs to be added after dispatch, even if we automatically add -compiler pytest
"https://github.com/tpope/vim-dispatch/issues/263
" Previously we had to explicitly pass -compiler=pytest -- <args>
" This is handled via b:dispatch
function! s:DispatchPytest(bang, args) abort
  execute 'Dispatch' . a:bang . ' -compiler=pytest -- ' . a:args
endfunction

function! pytest#dispatch#WithScope(scope, bang) abort
  let test_path = pytest#common#GetTestPath(a:scope)

  if empty(test_path)
    echo "Could not determine test path for scope: " . a:scope
    return
  endif

  call s:DispatchPytest(a:bang, test_path)
endfunction


" g:Prefer vim terminal for interactive processes
"   1 = Launch in terminal
"   0 = Launch in tmux window
function! pytest#dispatch#toggle_strategy() abort
  let g:dispatch_no_tmux_start = !get(g:, 'dispatch_no_tmux_start', 1)
  echo 'Default Start startegy set to terminal: ' . (g:dispatch_no_tmux_start ? 'on' : 'off')
endfunction
