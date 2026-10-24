" roumail/vim-prompts: a bare @ (or @dir/) in :Ai picks files with fzf-utils'
" fd picker, the same listing as :FdFiles.
let g:prompts_file_picker = 'fzf_utils#fd#files#pick'
" The agent starts in auto mode, approving what it judges safe; /review and
" --ask-mode still ask. Copilot needs its config set for this:
" copilot config defaultPermissionMode assisted
let g:prompts_mode = 'auto'
