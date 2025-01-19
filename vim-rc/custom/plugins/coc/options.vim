let g:go_def_mode='gopls'
let g:go_info_mode='gopls'

" Bad response https://registry.npmjs.org/coc-ruff: 404
" \ 'coc-ruff',
" \ 'coc-black-formatter'
let g:coc_global_extensions = [
    \ 'coc-json',
    \ 'coc-html',
    \ 'coc-pyright',
    \ 'coc-diagnostic',
    \ 'coc-sh',
    \ 'coc-docker',
    \ 'coc-highlight',
    \ 'coc-lightbulb',
    \ 'coc-nav',
    \ 'coc-toml',
    \ 'coc-yaml',
    \ 'coc-markdownlint'
    \ ]

" May need for Vim (not Neovim) since coc.nvim calculates byte offset by count
" utf-8 byte sequence
set encoding=utf-8
" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
" delays and poor user experience
set updatetime=300

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved
set signcolumn=yes