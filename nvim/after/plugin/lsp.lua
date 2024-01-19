local status, nvim_lsp = pcall(require, "lspconfig")
if (not status) then return end

local protocol = require('vim.lsp.protocol')



local lsp = require("lsp-zero")



lsp.preset("recommended")

lsp.ensure_installed({
  'tsserver',
  'rust_analyzer',
})

-- TypeScript
nvim_lsp.tsserver.setup {
  on_attach = on_attach,
  filetypes = { "javascript", "typescript", "typescriptreact", "typescript.tsx" },
  cmd = { "typescript-language-server", "--stdio" }
} 

-- Fix Undefined global 'vim'
lsp.nvim_workspace()


local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-y>'] = cmp.mapping.confirm({ select = true }),
  ["<C-Space>"] = cmp.mapping.complete(),
})

cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

lsp.setup_nvim_cmp({
  mapping = cmp_mappings
})

local M = {}

local lsp_setup_opts = {}
M.lsp_setup_opts = lsp_setup_opts

-- (lsp_name: string) => function(client, init_result), see :help vim.lsp.start_client()
local on_init = {}
M.on_init = {}

lsp_setup_opts['pyright'] = {
  settings = {
    -- https://github.com/microsoft/pyright/blob/main/docs/settings.md
    python = {
      analysis = {
        typeCheckingMode = "basic",
      }
    },
  },
}

lsp_setup_opts['ruff_lsp'] = {
  init_options = {
    -- https://github.com/charliermarsh/ruff-lsp#settings
    settings = {
      fixAll = true,
      organizeImports = false,  -- let isort take care of organizeImports
      -- extra CLI arguments
      -- https://beta.ruff.rs/docs/configuration/#command-line-interface
      -- https://beta.ruff.rs/docs/rules/
      args = { "--ignore", table.concat({
        "E402", -- module-import-not-at-top-of-file
        "E501", -- line-too-long
        "E731", -- lambda-assignment
      }, ',') },
    },
  }
}

lsp.set_preferences({
    suggest_lsp_servers = false,
    sign_icons = {
        error = 'E',
        warn = 'W',
        hint = 'H',
        info = 'I'
    }
})

local client = vim.lsp.get_active_clients()[1]

if client then
  local on_attach = function(client, bufnr)
    local opts = {buffer = bufnr, remap = false}
    
    if vim.bo[bufnr].buftype ~= "" or vim.bo[bufnr].filetype == "helm" then
        vim.diagnostic.disable() 
    end

    -- format on save
    if client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("Format", { clear = true }),
        buffer = bufnr,
        callback = function() vim.lsp.buf.format_seq_sync() end
      })
    end
      
    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
  end
end

lsp.on_attach(on_attach)




lsp.setup()

vim.diagnostic.config({
    virtual_text = true
})


