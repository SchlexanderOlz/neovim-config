vim.opt.colorcolumn = "80"

require("core.utils").load_mappings()

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

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

vim.api.nvim_command("set guifont=JetBrainsMono\\ Nerd\\ Font\\ Mono:h15")

vim.g.opamshare = fn.substitute(fn.system('opam var share'), '\n$', '', '')
cmd("set rtp+=" .. vim.g.opamshare .. "/merlin/vim")

-- Configure nvim-ocamlformat
vim.g.ocamlformat_options = '--enable-outside-detected-project'

vim.g.LanguageClient_serverCommands = {
    ocaml = {"ocamllsp"},
}
cmd('call plug#begin("~/.vim/plugged")')
cmd('call plug#end()')

vim.g.ale_sign_error = '✘'
vim.g.ale_sign_warning = '⚠'
cmd("highlight ALEErrorSign ctermbg=NONE ctermfg=red")
cmd("highlight ALEWarningSign ctermbg=NONE ctermfg=yellow")
vim.g.ale_linters_explicit = 1
vim.g.ale_lint_on_text_changed = 'never'
vim.g.ale_lint_on_enter = 0
vim.g.ale_lint_on_save = 1
vim.g.ale_fix_on_save = 1

vim.g.ale_linters = {
    ocaml = {'ocamlformat'},
}

vim.g.ale_fixers = {
    ocaml = {'ocamlformat'},
    ['*'] = {'remove_trailing_lines', 'trim_whitespace'},
}


api.nvim_set_keymap('n', '<silent> K', ':call LanguageClient#textDocument_hover()<CR>', {noremap = true})
api.nvim_set_keymap('n', '<silent> gd', ':call LanguageClient#textDocument_definition()<CR>', {noremap = true})
api.nvim_set_keymap('n', '<silent> <F2>', ':call LanguageClient#textDocument_rename()<CR>', {noremap = true})

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

