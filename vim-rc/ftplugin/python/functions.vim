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

" Handle {'foo': True, 'bar': None}
"  This works but not as a function due to escaping
"  :%!python3 -c "import ast,json,sys;obj=ast.literal_eval(sys.stdin.read());print(json.dumps(obj,sort_keys=True,indent=2))"
function! NormalizePythonDict() abort
  let l:script = 'import ast,json,sys;obj=ast.literal_eval(sys.stdin.read());print(json.dumps(obj,sort_keys=True,indent=2,ensure_ascii=False))'
  execute '%!python3 -c ' . shellescape(l:script)
endfunction

" handles '{"foo": true, "bar": null}'
"  This works but not as a function due to escaping
"  :%!python3 -c "import ast,json,sys;s=ast.literal_eval(sys.stdin.read());obj=json.loads(s);print(json.dumps(obj,sort_keys=True,indent=2))"
function! NormalizeJsonString() abort
  let l:script = 'import ast,json,sys;s=ast.literal_eval(sys.stdin.read());obj=json.loads(s);print(json.dumps(obj,sort_keys=True,indent=2,ensure_ascii=False))'
  execute '%!python3 -c ' . shellescape(l:script)
endfunction

command! NormalizeJsonString call NormalizeJsonString()
command! NormalizePythonDict call NormalizePythonDict()

function! NormalizeSplitDiff() abort
  if winnr('$') < 2
    echoerr 'NormalizeSplitDiff needs at least 2 windows'
    return
  endif

  let l:cur = winnr()

  " Left window: JSON string
  execute '1wincmd w'
  call NormalizeJsonString()
  setlocal filetype=python

  " Right window: Python dict
  execute '2wincmd w'
  call NormalizePythonDict()
  setlocal filetype=python

  " Diff mode in both
  execute '1wincmd w'
  diffthis
  execute '2wincmd w'
  diffthis

  execute l:cur . 'wincmd w'
endfunction

command! NormalizeSplitDiff call NormalizeSplitDiff()