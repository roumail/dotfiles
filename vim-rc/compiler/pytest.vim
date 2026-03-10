" filepath: ~/.vim/compiler/pytest.vim
if exists("current_compiler")
  finish
endif
let current_compiler = "pytest"

CompilerSet makeprg=chkpyt.sh\ $*
" Pytest error format
CompilerSet errorformat=
    \%E%f:%l:\ %m,
    \%EFAILED\ %f::%m,
    \%EERROR\ %f::%m,
    \%C%.%#,
    \%-G%.%#
