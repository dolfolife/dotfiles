require('mason').setup()
require('mason-lspconfig').setup({
    ensure_installed = {
        'gopls',
        'kotlin_language_server',
        'lua_ls',
        'gradle_ls',
        'hls',
        'jsonls',
        'eslint',
        'pyright',
        'ts_ls'
    },
    automatic_installation = true,
})
