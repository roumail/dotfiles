if exists('b:loaded_python_pytest_ftplugin')
  finish
endif
let b:loaded_python_pytest_ftplugin = 1

" Copy test paths to clipboard/register without running
command! -buffer YankTestMethod call pytest#common#YankTestPath('method')
command! -buffer YankTestClass call pytest#common#YankTestPath('class')
command! -buffer YankTestFunction call pytest#common#YankTestPath('function')
command! -buffer YankTestFile call pytest#common#YankTestPath('file')

command! -buffer -bang -nargs=1 RunPytest call pytest#dispatch#RunTest(<q-args>, "<bang>")

command! -buffer -nargs=1 -bang RunPytestTrace call pytest#dispatch#RunTestWithTrace(<q-args>, "<bang>")