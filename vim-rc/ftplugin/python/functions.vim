if exists('b:loaded_python_functions_ftplugin')
  finish
endif
let b:loaded_python_functions_ftplugin = 1

augroup pytest_parse
  autocmd!
  " This runs AFTER dispatch completes and populates quickfix
  autocmd QuickFixCmdPost dispatch call ParsePytestFailures()
augroup END

