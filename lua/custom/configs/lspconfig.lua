local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"

lspconfig.rust_analyzer.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {"rust"},
  root_dir = lspconfig.util.root_pattern("Cargo.toml"),
})

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
      -- Add any other ocamllsp-specific settings here, if applicable
    },
  },
})
