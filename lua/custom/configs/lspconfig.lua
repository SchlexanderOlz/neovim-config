local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
local opts = { noremap=true, silent=true }

local os = require('os')
local omnisharp_bin;
if os.getenv("OSTYPE") == "linux-gnu" then
  omnisharp_bin = "/home/schlexander/source/omnisharp/OmniSharp"
else
  omnisharp_bin = 'C:\\Users\\scholz3\\lsps\\omnisharp-win-x64-net6.0\\OmniSharp.exe'
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

if client.resolved_capabilities.document_highlight then
  vim.api.nvim_exec([[
    hi LspReferenceRead cterm=bold ctermbg=DarkMagenta guibg=LightYellow
    hi LspReferenceText cterm=bold ctermbg=DarkMagenta guibg=LightYellow
    hi LspReferenceWrite cterm=bold ctermbg=DarkMagenta guibg=LightYellow
    augroup lsp_document_highlight
      autocmd! * <buffer>
      autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
      autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
    augroup END
  ]], false)
end
end

lspconfig.ocamllsp.setup({
  cmd = {"ocamllsp"}, -- Specify the command to launch the ocamllsp executable
  on_attach = on_attach, -- Define your custom on_attach function
  capabilities = capabilities, -- Provide custom capabilities
  root_dir = lspconfig.util.root_pattern("*.opam", "esy.json", "package.json", "dune"), -- Specify how to find the project root directory
  filetypes = {"ocaml", "reason"}, -- Define the filetypes associated with OCaml/ReasonML
  settings = {
    ocamllsp = {
      lsp = {
        diagnostics = true, -- Enable diagnostics (errors and warnings)
        debounce = 100, -- Set a debounce time for diagnostics (in milliseconds)
      },
    },
  },
})

vim.g.ocamlformat_options = '--enable-outside-detected-project'

vim.g.LanguageClient_serverCommands = {
    ocaml = {"ocamllsp"},
}

vim.g.ale_linters = {
    ocaml = {'ocamlformat'},
}

vim.g.ale_fixers = {
    ocaml = {'ocamlformat'},
    ['*'] = {'remove_trailing_lines', 'trim_whitespace'},
}

lspconfig.omnisharp.setup({
  cmd = { omnisharp_bin, "--languageserver", "--hostPID", tostring(pid) },
  on_attach = on_attach
})

lspconfig.rust_analyzer.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {"rust"},
  root_dir = lspconfig.util.root_pattern("Cargo.toml"),
})

lspconfig.gopls.setup{
	cmd = {'gopls'},
	-- for postfix snippets and analyzers
	capabilities = capabilities,
	    settings = {
	      gopls = {
		      experimentalPostfixCompletions = true,
		      analyses = {
		        unusedparams = true,
		        shadow = true,
		     },
		     staticcheck = true,
		    },
	    },
	on_attach = on_attach,
}

  function goimports(timeoutms)
    local context = { source = { organizeImports = true } }
    vim.validate { context = { context, "t", true } }

    local params = vim.lsp.util.make_range_params()
    params.context = context

    -- See the implementation of the textDocument/codeAction callback
    -- (lua/vim/lsp/handler.lua) for how to do this properly.
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, timeoutms)
    if not result or next(result) == nil then return end
    local actions = result[1].result
    if not actions then return end
    local action = actions[1]

    -- textDocument/codeAction can return either Command[] or CodeAction[]. If it
    -- is a CodeAction, it can have either an edit, a command or both. Edits
    -- should be executed first.
    if action.edit or type(action.command) == "table" then
      if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit)
      end
      if type(action.command) == "table" then
        vim.lsp.buf.execute_command(action.command)
      end
    else
      vim.lsp.buf.execute_command(action)
    end
  end


lspconfig.tsserver.setup({
  init_options = require("nvim-lsp-ts-utils").init_options,

  on_attach = function(client, bufnr)
    local ts_utils = require("nvim-lsp-ts-utils")
    ts_utils.setup_client(client)

    local opts = { silent = true }
  end,
})

lspconfig.zls.setup{}
lspconfig.texlab.setup{}

local ccls_config = {
  filetypes = { 'c', 'cpp', 'ino' }, -- Add 'ino' here
}
lspconfig.ccls.setup(ccls_config)
