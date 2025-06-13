return {
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.completion = opts.completion or {}
      opts.completion.list = opts.completion.list or {}
      opts.completion.list.selection = {
        preselect = true,
        auto_insert = false,
      }
      opts.keymap = {
        preset = "default",
        ["<C-space>"] = {},
        ["<C-k>"] = { "show_documentation", "hide_documentation", "fallback" },
        ["<C-n>"] = { "select_next", "show", "fallback" },
      }

      return opts
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.inlay_hints = { enabled = false }

      opts.servers.gopls.settings.gopls.usePlaceholders = false

      opts.servers.vtsls.settings.complete_function_calls = false
      opts.servers.vtsls.settings.typescript.suggest.completeFunctionCalls = false

      opts.servers.phpactor.enabled = vim.g.lazyvim_php_lsp == "phpactor"

      opts.servers.intelephense.enabled = vim.g.lazyvim_php_lsp == "intelephense"
      opts.servers.intelephense.init_options = {
        globalStoragePath = vim.env.HOME .. "/.config/intelephense",
        licenceKey = vim.env.HOME .. "/.config/intelephense/licence.txt",
      }
      opts.servers.intelephense.settings = {
        intelephense = {
          maxMemory = 4096,
          format = {
            enable = false,
          },
          files = {
            exclude = {
              "**/.git/**",
              "**/.svn/**",
              "**/.hg/**",
              "**/CVS/**",
              "**/.DS_Store/**",
              "**/.phpstan/**",
              "**/libs/**",
              "**/node_modules/**",
              "**/bower_components/**",
              "**/vendor/**/{Tests,tests}/**",
              "**/.history/**",
              "**/vendor/**/vendor/**",
            },
          },
        },
      }
    end,
  },
}
