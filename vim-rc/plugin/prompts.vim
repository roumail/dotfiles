" roumail/vim-prompts: a bare @ (or @dir/) in :Ai picks files with fzf-utils'
" fd picker, the same listing as :FdFiles.
let g:prompts_file_picker = 'fzf_utils#pick_files'
" The agent starts in auto mode, approving what it judges safe; /review and
" --ask-mode still ask. Copilot needs its config set for this:
" copilot config defaultPermissionMode assisted
let g:prompts_mode = 'auto'
" A Copilot one-off (:Ai) runs with --allow-all: its assisted judge refused
" too much. vim-prompts' default is the judge; to set it back, in a project's
" .vim.custom:
" let g:prompts_copilot_approval = 'assisted'
let g:prompts_copilot_approval = 'all'
