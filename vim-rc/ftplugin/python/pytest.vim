if exists('b:loaded_python_pytest_ftplugin')
  finish
endif
let b:loaded_python_pytest_ftplugin = 1

" Copy test paths to clipboard/register without running
command! -buffer YankTestMethod call pytest#common#YankTestPath('method')
command! -buffer YankTestClass call pytest#common#YankTestPath('class')
command! -buffer YankTestFunction call pytest#common#YankTestPath('function')
command! -buffer YankTestFile call pytest#common#YankTestPath('file')

" Direct Pytest dispatch with custom args, to run all tests for example
command! -buffer -bang -nargs=* RunPytest call pytest#dispatch#Dispatch("<bang>", <q-args>)
" TracePytest - automatically adds --trace for interactive debugging with custom args
command! -buffer -bang -nargs=* TracePytest call pytest#dispatch#StartPytest(<q-args> . ' --trace')
" Scope-based shortcuts
command! -buffer -bang -nargs=1 RunPytestScope call pytest#dispatch#WithScope(<q-args>, "<bang>")
command! -buffer -nargs=1 -bang RunPytestScopeTrace call pytest#dispatch#WithScopeAndTrace(<q-args>, "<bang>")
