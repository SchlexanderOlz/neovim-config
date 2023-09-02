local plugins = {
  {
    "vim-crystal/vim-crystal",
    ft = "crystal",
    config = function(_)
      vim.g.crystal_auto_format = 1
    end
  },
  {
    "OmniSharp/omnisharp-vim",
    config = function ()
    end
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  {
    "dense-analysis/ale",
    config = function ()
    end
  },
  {
    "simrat39/rust-tools.nvim",
    config = function ()
    end
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "rust-analyzer",
      }
    }
  },
  {
    "HallerPatrick/py_lsp.nvim",
    config = function ()
    end
  },
  {
    "zigtools/zls",
    config = function()
    end
  },
}
return plugins
