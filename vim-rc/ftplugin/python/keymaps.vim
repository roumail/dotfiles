if exists('b:loaded_python_keymaps_ftplugin')
  finish
endif
let b:loaded_python_keymaps_ftplugin = 1

function! s:SetupPytestKeymaps() abort
    if expand('%:t') !~ '^test_'
        return
    endif
    
    
    " Run with --pdb in terminal
    nnoremap <buffer> <localleader>dm :RunPytestTrace! method<CR>
    nnoremap <buffer> <localleader>dc :RunPytestTrace! class<CR>
    nnoremap <buffer> <localleader>df :RunPytestTrace! function<CR>
    nnoremap <buffer> <localleader>dt :RunPytestTrace! file<CR>

    " Run with --trace in terminal
    nnoremap <buffer> <localleader>tm :RunPytestTrace method<CR>
    nnoremap <buffer> <localleader>tc :RunPytestTrace class<CR>
    nnoremap <buffer> <localleader>tf :RunPytestTrace function<CR>
    nnoremap <buffer> <localleader>tt :RunPytestTrace file<CR>
    
    " Yank test paths
    nnoremap <buffer> <localleader>ym :YankTestMethod<CR>
    nnoremap <buffer> <localleader>yc :YankTestClass<CR>
    nnoremap <buffer> <localleader>yf :YankTestFunction<CR>
    nnoremap <buffer> <localleader>yF :YankTestFile<CR>
endfunction

let maplocalleader = "_"

augroup python_pytest_keymaps
    autocmd!
    autocmd BufEnter <buffer> call s:SetupPytestKeymaps()
augroup END
