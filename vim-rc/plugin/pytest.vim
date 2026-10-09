" roumail/pytest.vim runs plain pytest by default; route it through chkpyt.sh
" (.config/shell/bin), which adds baseline addopts and reads .env.
let g:pytest_command = 'chkpyt.sh'
" Interactive --trace / --pdb sessions skip the baseline addopts
let g:pytest_debug_command = 'chkpyt.sh --no-default-addopts'

" Keys in test files: action prefix + scope letter, e.g. _rm runs the method
let g:pytest_mappings = {
      \ 'run': '<localleader>r',
      \ 'trace': '<localleader>t',
      \ 'pdb': '<localleader>d',
      \ 'yank': '<localleader>y',
      \ 'scopes': {'method': 'm', 'class': 'c', 'function': 'f', 'file': 't'},
      \ 'yank-file': '<localleader>yF',
      \ }
