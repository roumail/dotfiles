" --- Global LSP Settings ---

let g:lsp_use_native_client = 1
let g:lsp_log_verbose = 1
let g:lsp_log_file = expand('~/vim-lsp.log')
let g:lsp_diagnostics_enabled = 1 
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


" -- Vim lsp settings config ---
let g:lsp_settings_filetype_json = 'json-languageserver'
let g:lsp_settings_filetype_yaml = 'yaml-language-server'
let g:lsp_settings_filetype_python = 'ty'
" These settings seem to be ignored
let g:lsp_settings = {
\  'ty': {
\    "workspace_config": {
\      'ty': {
\        'diagnosticMode': 'workspace',
\        'showSyntaxErrors': v:true,
\        'inlayHints': {
\          'variableTypes': v:true,
\          'callArgumentNames': v:true
\        },
\        'completions': {
\          'autoImport': v:true
\        }
\      }
\    },
\    "initialization_options": {
\      'logFile': expand('~/.local/ty.log'),
\      'logLevel': 'debug'
\    }
\  }
\}

" lsp config
" autocmd User LspSetup call LspOptionsSet(lspOpts)

" let g:lsp_options = {
"     \ 'autoHighlight': v:true,
"     \ 'autoPopulateDiags': v:false,
"     \ 'showDiagWithSign': v:false,
"     \ 'completionMatcher': 'fuzzy',
"     \ }




