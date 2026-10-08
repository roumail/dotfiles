" Local overrides, sourced last so they win over everything in vim-rc/.

" Machine-specific settings, not in git (e.g. g:github_enterprise_urls)
if filereadable(expand('~/.vim.local'))
    source ~/.vim.local
endif

" Project-local settings from the directory Vim was started in (see the
" example vim-rc/.vim.custom)
if filereadable('.vim.custom')
    source .vim.custom
endif
