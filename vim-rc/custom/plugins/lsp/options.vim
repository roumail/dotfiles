" --- Global LSP Settings ---

let g:lsp_use_native_client = 1
let g:lsp_auto_enable = 0
let g:lsp_log_verbose = 1
let g:lsp_log_file = expand('~/vim-lsp.log')
let g:lsp_diagnostics_enabled = 1 
" highlight link lspReference Search
let g:lsp_diagnostics_highlights_enabled = 1
let g:lsp_document_code_action_signs_enabled = 1
let g:lsp_inlay_hints_enabled = 0
let g:lsp_completion_documentation_enabled = 0
let g:lsp_document_highlight_enabled = 1
let g:lsp_signature_help_enabled = 0
let g:lsp_fold_enabled = 0
" Preview remains open and expects an explicit close call| None = Non
" <Plug>(lsp-peek-implementation)e
let g:lsp_preview_autoclose = 0
" Opens preview windows as normal windows
let g:lsp_preview_float = 0
" Do not keep the focus in current window.
" Move the focus to |preview-window|.
let g:lsp_preview_keep_focus= 0
" '', 'float', 'preview'
" let g:lsp_hover_ui = 'preview'
let g:lsp_semantic_enabled = 0
" Internal command used to delay starting the lsp
let g:lsp_delayed_started = 0
" -- Vim lsp settings config ---
let g:lsp_settings_filetype_json = 'json-languageserver'
let g:lsp_settings_filetype_yaml = 'yaml-language-server'
let g:lsp_settings_filetype_python = 'ty'
let g:lsp_settings_filetype_python = 'ty'
let g:lsp_settings_filetype_rust = ['rust-analyzer']
" https://github.com/astral-sh/ty/issues/2851#issuecomment-3928167194
let g:lsp_settings = {
      \  'ty': {
      \    "initialization_options": {
      \      'logFile': expand('~/.local/ty.log'),
      \      'diagnosticMode': 'workspace',
      \      'showSyntaxErrors': v:true ,
      \      'inlayHints': {
      \         'variableTypes': v:true,
      \         'callArgumentNames': v:true,
      \       }, 
      \      'configurationFile': expand('~/.config/ty.toml'),
      \      'completions': {
      \         'autoImport': v:true,
      \    }
      \    }
      \  },
      \ 'rust-analyzer': {
      \   'initialization_options': {
      \     'checkOnSave': v:false,
      \     'diagnostics': v:false,
      \   }
      \}
      \}




