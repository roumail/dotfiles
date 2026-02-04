" This tells the plugin how to start pyright
if executable('pyright-langserver')
    au User LspSetup call LspAddServer([#{
        \  name: 'pyright',
        \  filetype: ['python'],
        \  path: 'pyright-langserver',
        \  args: ['--stdio']
        \ }])
endif




