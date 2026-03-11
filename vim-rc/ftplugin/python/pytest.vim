" File:        pytest.vim
" Description: Runs the current test Class/Method/Function/File with
"              py.test
" Maintainer:  Alfredo Deza <alfredodeza AT gmail.com>
" License:     MIT
"============================================================================
function! s:NameOfCurrentClass()
    let save_cursor = getpos(".")
    normal! $<cr>
    let find_object = s:FindPythonObject('class')
    if (find_object)
        let line = getline('.')
        call setpos('.', save_cursor)
        let match_result = matchlist(line, ' *class \+\(\w\+\)')
        return match_result[1]
    endif
endfunction

function! s:NameOfCurrentFunction()
    normal! $<cr>
    let find_object = s:FindPythonObject('function')
    if (find_object)
        let line = getline('.')
        let match_result = matchlist(line, ' *def \+\(test\w\+\)')
        echom("match_result: " . string(match_result))
        return match_result[1]
    endif
endfunction

function! s:NameOfCurrentMethod()
    normal! $<cr>
    let find_object = s:FindPythonObject('method')
    if (find_object)
        let line = getline('.')
        let match_result = matchlist(line, ' *def \+\(\w\+\)')
        return match_result[1]
    endif
endfunction

" Always goes back to the first instance
" and returns that if found
function! s:FindPythonObject(obj)
    let orig_line   = line('.')
    let orig_col    = col('.')
    let orig_indent = indent(orig_line)


    if (a:obj == "class")
        let objregexp  = '\v^\s*(.*class)\s+(\w+)\s*'
        let max_indent_allowed = 0
    elseif (a:obj == "method")
        let objregexp = '\v^\s*(.*def)\s+(\w+)\s*\(\_s*(self[^)]*)'
        let max_indent_allowed = 4
    else
        let objregexp = '\v^\s*(.*def)\s+(test\w+)\s*\(\_s*(.*self)@!'
        let max_indent_allowed = orig_indent
    endif

    let flag = "Wb"

    while search(objregexp, flag) > 0
        "
        " Very naive, but if the indent is less than or equal to four
        " keep on going because we assume you are nesting.
        " Do not count lines that are comments though.
        "
        if (indent(line('.')) <= 4) && !(getline(line('.')) =~ '\v^\s*#(.*)')
          if (indent(line('.')) <= max_indent_allowed)
            return 1
          endif
        endif
    endwhile

endfunction

" ============================================================================
" Smart Dispatch Commands
" ============================================================================

command! -buffer -bang PytestMethod call s:RunMethod("<bang>")
command! -buffer -bang PytestClass call s:RunClass("<bang>")
command! -buffer -bang PytestFunction call s:RunFunction("<bang>")
command! -buffer -bang PytestSmart call s:RunSmart("<bang>")

function! s:RunMethod(bang) abort
    let method = s:NameOfCurrentMethod()
    let class = s:NameOfCurrentClass()
    
    if empty(method) || empty(class)
        echo "Not inside a test method"
        return
    endif
    
    execute 'Pytest' . a:bang . ' % -k ' . method
endfunction

function! s:RunClass(bang) abort
    let class = s:NameOfCurrentClass()
    
    if empty(class)
        echo "Not inside a test class"
        return
    endif
    
    execute 'Pytest' . a:bang . ' %::' . class
endfunction

function! s:RunFunction(bang) abort
    let func = s:NameOfCurrentFunction()
    
    if empty(func)
        echo "Not inside a test function"
        return
    endif
    
    execute 'Pytest' . a:bang . ' %::' . func
endfunction

function! s:RunSmart(bang) abort
    let method = s:NameOfCurrentMethod()
    if !empty(method)
        call s:RunMethod(a:bang)
        return
    endif
    
    let func = s:NameOfCurrentFunction()
    if !empty(func)
        call s:RunFunction(a:bang)
        return
    endif
    
    execute 'Pytest' . a:bang . ' %'
endfunction