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
  let l:script = join([
        \ 'import ast, json, sys',
        \ 'obj = ast.literal_eval(sys.stdin.read())',
        \ 'print(json.dumps(',
        \ '    obj,',
        \ '    sort_keys=True,',
        \ '    indent=2,',
        \ '    ensure_ascii=False',
        \ '))',
        \ ], "\n")

  execute '%!python3 -c ' . shellescape(l:script)
endfunction

" handles '{"foo": true, "bar": null}'
"  This works but not as a function due to escaping
"  :%!python3 -c "import ast,json,sys;s=ast.literal_eval(sys.stdin.read());obj=json.loads(s);print(json.dumps(obj,sort_keys=True,indent=2))"
function! NormalizeJsonString() abort
  let l:script = join([
        \ 'import ast, json, sys',
        \ 's = ast.literal_eval(sys.stdin.read())',
        \ 'obj = json.loads(s)',
        \ 'print(json.dumps(',
        \ '    obj,',
        \ '    sort_keys=True,',
        \ '    indent=2,',
        \ '    ensure_ascii=False',
        \ '))',
        \ ], "\n")

  execute '%!python3 -c ' . shellescape(l:script)
endfunction

command! NormalizeJsonString call NormalizeJsonString()
command! NormalizePythonDict call NormalizePythonDict()
