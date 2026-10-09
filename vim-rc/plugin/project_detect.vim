" roumail/project-detect runs Python tests with plain pytest by default; route
" them through chkpyt.sh (.config/shell/bin), which adds baseline addopts and
" reads .env. Interactive --trace / --pdb sessions skip the baseline addopts.
let g:project_detect_runners = {
      \ 'python': {'run': 'chkpyt.sh', 'debug': 'chkpyt.sh --no-default-addopts'},
      \ }
