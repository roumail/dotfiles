" Load plugin initialization
source ~/.vim/custom/plug.vim

" Load plugin configurations
source ~/.vim/custom/plugins/palenight.vim

" Leader key
let mapleader = " "

" Load coc configurations ---
source ~/.vim/custom/plugins/coc/autocmds.vim
source ~/.vim/custom/plugins/coc/commands.vim
source ~/.vim/custom/plugins/coc/ui.vim
source ~/.vim/custom/plugins/coc/options.vim

" Load coc key maps ---
source ~/.vim/custom/plugins/coc/keymaps/completions.vim
source ~/.vim/custom/plugins/coc/keymaps/navigation.vim
source ~/.vim/custom/plugins/coc/keymaps/codeactions.vim
source ~/.vim/custom/plugins/coc/keymaps/lists.vim
source ~/.vim/custom/plugins/coc/keymaps/misc.vim

" Load fzf key maps ---
source ~/.vim/custom/plugins/fzf/options.vim
source ~/.vim/custom/plugins/fzf/keymaps.vim
source ~/.vim/custom/plugins/fzf/commands.vim

"source ~/.vim/custom/plugins/airline.vim
"source ~/.vim/custom/plugins/fern.vim

" Load general settings and mappings
source ~/.vim/custom/options.vim
source ~/.vim/custom/keymaps.vim
source ~/.vim/custom/ui.vim
" source ~/.vim/custom/clipboard.vim

" Add autocommands
source ~/.vim/custom/autocmds.vim

" Misc
source ~/.vim/custom/misc.vim