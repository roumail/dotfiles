if exists('b:loaded_python_functions_ftplugin')
  finish
endif
let b:loaded_python_functions_ftplugin = 1

function! ParsePytestFailures()
    " Keep only FAILED / ERROR lines
    g!/^FAILED\|^ERROR/d
    "
    " 2. Remove the FAILED/ERROR prefix (using regex instead of norm)
    %s/^\(FAILED\|ERROR\) //e
    "" 3. Remove the trailing error message (the part after ' - ')
    " Pytest separates the Node ID from the error with ' - '
    %s/\s-.*$//e 
    " Sort and remove duplicates
    sort u
endfunction


augroup pytest_parse
    autocmd!
    " This runs AFTER dispatch completes and populates quickfix
    autocmd QuickFixCmdPost dispatch call ParsePytestFailures()
augroup END
