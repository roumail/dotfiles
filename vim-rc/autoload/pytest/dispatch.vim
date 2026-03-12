" Helper function to run pytest with trace in terminal
function! pytest#dispatch#RunTestWithTrace(scope, bang) abort
    let test_path = pytest#common#GetTestPath(a:scope)
    
    if empty(test_path)
        echo "Could not determine test path for scope: " . a:scope
        return
    endif
    
    let debug_flag = empty(a:bang) ? '--trace' : '--pdb'
    execute 'Start! -strategy=terminal pytest ' . test_path . ' ' . debug_flag
endfunction

" -- needs to be added after dispatch, even if we automatically add -compiler pytest
"https://github.com/tpope/vim-dispatch/issues/263
" Previously we had to explicitly pass -compiler=pytest -- <args>
" This is handled via b:dispatch
function! s:DispatchPytest(bang, args) abort
    execute 'Dispatch' . a:bang . ' -compiler=pytest -- ' . a:args
endfunction

function! pytest#dispatch#RunTest(scope, bang) abort
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
