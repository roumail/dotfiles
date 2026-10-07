" roumail/pytest.vim runs plain pytest by default; route it through chkpyt.sh
" (.config/shell/bin), which adds baseline addopts and reads .env.
let g:pytest_command = 'chkpyt.sh'
" Interactive --trace / --pdb sessions skip the baseline addopts
let g:pytest_debug_command = 'chkpyt.sh --no-default-addopts'
