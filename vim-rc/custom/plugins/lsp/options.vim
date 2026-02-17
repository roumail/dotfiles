" --- Global LSP Settings ---

let g:lsp_use_native_client = 1
let g:lsp_log_verbose = 1
let g:lsp_log_file = expand('~/vim-lsp.log')
let g:lsp_diagnostics_enabled = 0 
let g:lsp_diagnostics_highlights_enabled = 0
let g:lsp_document_code_action_signs_enabled = 1
let g:lsp_inlay_hints_enabled = 1
let g:lsp_completion_documentation_enabled = 0
let g:lsp_document_highlight_enabled = 0
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
" lsp config
" let lspOpts = #{
"         \   aleSupport: v:false,
"         \   autoComplete: v:true,
"         \   autoHighlight: v:false,
"         \   autoHighlightDiags: v:true,
"         \   autoPopulateDiags: v:false,
"         \   completionMatcher: 'case',
"         \   completionMatcherValue: 1,
"         \   diagSignErrorText: 'E>',
"         \   diagSignHintText: 'H>',
"         \   diagSignInfoText: 'I>',
"         \   diagSignWarningText: 'W>',
"         \   echoSignature: v:false,
"         \   hideDisabledCodeActions: v:false,
"         \   highlightDiagInline: v:true,
"         \   hoverInPreview: v:false,
"         \   completionInPreview: v:false,
"         \   closePreviewOnComplete: v:true,
"         \   ignoreMissingServer: v:false,
"         \   keepFocusInDiags: v:true,
"         \   keepFocusInReferences: v:true,
"         \   completionTextEdit: v:true,
"         \   diagVirtualTextAlign: 'above',
"         \   diagVirtualTextWrap: 'default',
"         \   noNewlineInCompletion: v:false,
"         \   omniComplete: v:null,
"         \   omniCompleteAllowBare: v:false,
"         \   outlineOnRight: v:false,
"         \   outlineWinSize: 20,
"         \   popupBorder: v:true,
"         \   popupBorderHighlight: 'Title',
"         \   popupBorderHighlightPeek: 'Special',
"         \   popupBorderSignatureHelp: v:false,
"         \   popupHighlightSignatureHelp: 'Pmenu',
"         \   popupHighlight: 'Normal',
"         \   semanticHighlight: v:true,
"         \   showDiagInBalloon: v:true,
"         \   showDiagInPopup: v:true,
"         \   showDiagOnStatusLine: v:false,
"         \   showDiagWithSign: v:true,
"         \   showDiagWithVirtualText: v:false,
"         \   showInlayHints: v:false,
"         \   showSignature: v:true,
"         \   snippetSupport: v:false,
"         \   ultisnipsSupport: v:false,
"         \   useBufferCompletion: v:false,
"         \   usePopupInCodeAction: v:false,
"         \   useQuickfixForLocations: v:false,
"         \   vsnipSupport: v:false,
"         \   bufferCompletionTimeout: 100,
"         \   customCompletionKinds: v:false,
"         \   completionKinds: {},
"         \   filterCompletionDuplicates: v:false,
"         \   condensedCompletionMenu: v:false,
" 	\ }

" autocmd User LspSetup call LspOptionsSet(lspOpts)

" let g:lsp_options = {
"     \ 'autoHighlight': v:true,
"     \ 'autoPopulateDiags': v:false,
"     \ 'showDiagWithSign': v:false,
"     \ 'completionMatcher': 'fuzzy',
"     \ }




