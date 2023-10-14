vim.opt.colorcolumn = "80"

require("core.utils").load_mappings()

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

vim.cmd('source ~/.config/nvim/syntax/asm.vim')

vim.api.nvim_command("set number")
vim.api.nvim_command("set relativenumber")

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

-- bootstrap lazy.nvim!
if not vim.loop.fs_stat(lazypath) then
  require("core.bootstrap").gen_chadrc_template()
  require("core.bootstrap").lazy(lazypath)
end

dofile(vim.g.base46_cache .. "defaults")
vim.opt.rtp:prepend(lazypath)
require "plugins"

local api = vim.api
local cmd = vim.cmd
local fn = vim.fn

vim.api.nvim_command("set guifont=JetBrainsMono\\ Nerd\\ Font\\ Mono:h16")

-- Configure nvim-ocamlformat
vim.g.ale_sign_error = '✘'
vim.g.ale_sign_warning = '⚠'
cmd("highlight ALEErrorSign ctermbg=NONE ctermfg=red")
cmd("highlight ALEWarningSign ctermbg=NONE ctermfg=yellow")
vim.g.ale_linters_explicit = 1
vim.g.ale_lint_on_text_changed = 'never'
vim.g.ale_lint_on_enter = 0
vim.g.ale_lint_on_save = 1
vim.g.ale_fix_on_save = 1

vim.cmd([[
  autocmd BufWritePre *.go lua vim.lsp.buf.format()
  autocmd BufWritePre *.go lua goimports(1000)
  autocmd BufWritePre *.ml lua vim.lsp.buf.format()
]])

api.nvim_set_keymap('n', '<leader> k', ':call LanguageClient#textDocument_hover()<CR>', {noremap = true})
api.nvim_set_keymap('n', '<leader> gd', ':call LanguageClient#textDocument_definition()<CR>', {noremap = true})
api.nvim_set_keymap('n', '<leader> <F2>', ':call LanguageClient#textDocument_rename()<CR>', {noremap = true})

local rt = require("rust-tools")

rt.setup({
  server = {
    on_attach = function(client, bufnr)
      client.server_capabilities.semanticTokensProvider = nil
      -- Hover actions
      vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
      -- Code action groups
      vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
    end,
  },
})

vim.cmd([[
  autocmd BufWritePost *.rs lua vim.lsp.buf.format()
]])

require'py_lsp'.setup {
  -- This is optional, but allows to create virtual envs from nvim
  host_python = "/usr/bin/python",
  default_venv_name = ".venv" -- For local venv
}

