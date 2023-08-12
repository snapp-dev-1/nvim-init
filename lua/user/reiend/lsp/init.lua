require('mason').setup()
require('mason-lspconfig').setup()

-- servers
require 'user.reiend.lsp.servers.lua_ls'
require 'user.reiend.lsp.servers.tsserver'

local efmls = require 'efmls-configs'

efmls.init { -- Enable formatting provided by efm langserver
  default_config = false,
  init_options = { documentFormatting = true },
}

local stylua = require 'efmls-configs.formatters.stylua'
stylua = vim.tbl_extend('force', stylua, {
  prefix = 'stylua',
  formatCommand = 'stylua --color Never -',
  formatStdin = true,
})

local prettier_d = require 'efmls-configs.formatters.prettier_d'
prettier_d = vim.tbl_extend('force', prettier_d, {
  prefix = 'prettier_d',
  formatCommand = 'prettier_d ${INPUT}',
  formatStdin = true,
})

local eslint_d = require 'efmls-configs.linters.eslint_d'
eslint_d = vim.tbl_extend('force', eslint_d, {
  prefix = 'eslint_d',
  lintCommand = 'eslint_d --no-color --format visualstudio --stdin',
  lintStdin = true,
  lintFormats = { '<text>(%l,%c): %trror %m', '<text>(%l,%c): %tarning %m' },
  lintIgnoreExitCode = true,
  rootMarkers = {
    '.eslintrc',
    '.eslintrc.cjs',
    '.eslintrc.js',
    '.eslintrc.json',
    '.eslintrc.yaml',
    '.eslintrc.yml',
    'package.json',
  },
})

local luacheck = require 'efmls-configs.linters.luacheck'
luacheck = vim.tbl_extend('force', luacheck, {
  prefix = 'luacheck',
  lintCommand = 'luacheck --codes --no-color --quiet -',
  lintStdin = true,
  lintFormats = { '%.%#:%l:%c: (%t%n) %m' },
  rootMarkers = { '.luacheckrc' },
})

efmls.setup {
  javascript = {
    -- linter = require 'efmls-configs.linters.eslint_d',
    -- formatter = require 'efmls-configs.formatters.prettier_d',
    linter = eslint_d,
    formatter = prettier_d,
  },
  typescript = {
    -- linter = require 'efmls-configs.linters.eslint_d',
    -- formatter = require 'efmls-configs.formatters.prettier_d',
    linter = eslint_d,
    formatter = prettier_d,
  },
  typescriptreact = {
    -- linter = require 'efmls-configs.linters.eslint_d',
    -- formatter = require 'efmls-configs.formatters.prettier_d',
    linter = eslint_d,
    formatter = prettier_d,
  },
  lua = {
    -- linter = require 'efmls-configs.linters.luacheck',
    -- formatter = require 'efmls-configs.formatters.stylua',
    linter = luacheck,
    formatter = stylua,
  },
}

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})
