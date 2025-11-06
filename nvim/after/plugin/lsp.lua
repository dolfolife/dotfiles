local capabilities = vim.lsp.protocol.make_client_capabilities()

-- You might want to get your capabilities from nvim-cmp if you are using it
-- capabilities = require('cmp_nvim_lsp').default_capabilities()

local on_attach = function(client, bufnr)
  -- Enable completion if using nvim-cmp
  -- client.server_capabilities.completionProvider = {
  --     resolveProvider = false,
  --     triggerCharacters = { '.', ':' },
  -- }

  local opts = { buffer = bufnr, remap = false }

  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "gI", vim.lsp.buf.implementation, opts) -- Corrected 'implmentations' to 'implementation'
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>ds", vim.lsp.buf.document_symbol, opts)
  vim.keymap.set("n", "<leader>ws", vim.lsp.buf.workspace_symbol, opts)
  vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  -- Duplicate mapping: <leader>gr is already for references. If you want it for
  -- a different action, change it.
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
end

-- Common settings for all language servers
local servers = {
  gopls = {},
  kotlin_language_server = {},
  lua_ls = {
    settings = {
      Lua = {
        runtime = {
          version = 'Lua51', -- Or your Lua version
        },
        diagnostics = {
          globals = { 'vim' },
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        telemetry = { enable = false, }, },
    },
  },
  gradle_ls = {},
  hls = {},
  jsonls = {
    settings = {
      json = {
        schemas = require('schemastore').json.schemas(),
        validate = { enable = true },
      },
    },
  },
  eslint = {},
  pyright = {},
  ts_ls = {}, -- Fixed: renamed from 'tsserver'
}

-- Setup each language server using the new vim.lsp.config API (Neovim 0.11+)
for lsp_name, config in pairs(servers) do
  vim.lsp.config[lsp_name] = {
    cmd = vim.lsp.config[lsp_name] and vim.lsp.config[lsp_name].cmd or { lsp_name },
    root_markers = vim.lsp.config[lsp_name] and vim.lsp.config[lsp_name].root_markers or { '.git' },
    capabilities = capabilities,
    settings = config.settings,
  }
  
  vim.api.nvim_create_autocmd('FileType', {
    pattern = vim.lsp.config[lsp_name].filetypes or '*',
    callback = function(args)
      vim.lsp.enable(lsp_name)
      if on_attach then
        on_attach(nil, args.buf)
      end
    end,
  })
end

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  float = {
    focusable = false,
    style = 'minimal',
    border = 'rounded',
    source = true,
    header = '',
    prefix = '',
  },
})
