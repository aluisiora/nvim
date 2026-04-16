local now_if_args, later = Config.now_if_args, Config.later

-- Language servers ===========================================================

-- Mason
now_if_args(function()
  vim.pack.add({ "https://github.com/mason-org/mason.nvim" })
  require("mason").setup({})
end)

-- LSPs
later(function()
  vim.pack.add({ "https://github.com/j-hui/fidget.nvim" })
  require("fidget").setup()
  -- stylua: ignore
  vim.lsp.enable({
    "lua_ls",               -- lua
    "intelephense",         -- php
    "gopls",                -- go
    "vtsls",                -- typescript/javascript
    "cucumberls",           -- gherkin
    "superhtml", "emmetls", -- html
    "cssls",                -- css
    "bashls",               -- bash
    "nixd",                 -- nix
    "vacuum",               -- openapi/swagger
  })
end)

-- Flutter
later(function()
  vim.pack.add({
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/nvim-flutter/flutter-tools.nvim",
  })
  if Config.has_executable("flutter") then
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local mini_caps = MiniCompletion.get_lsp_capabilities()
    capabilities = vim.tbl_deep_extend("force", capabilities, mini_caps)
    capabilities = vim.tbl_deep_extend("force", capabilities, {
      workspace = {
        fileOperations = {
          didRename = true,
          willRename = true,
        },
      },
    })

    require("flutter-tools").setup({
      flutter_lookup_cmd = "mise where flutter",
      widget_guides = {
        enabled = true,
      },
      lsp = {
        capabilities = capabilities,
        settings = {
          updateImportsOnRename = true,
          renameFilesWithClasses = "always",
        },
      },
    })
  end
end)

-- Formatting =================================================================
later(function()
  vim.pack.add({ "https://github.com/stevearc/conform.nvim" })
  local conform = require("conform")
  local formatters = {
    lua = { "stylua" },
    php = { "php_cs_fixer" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    html = { "superhtml" },
    css = { "prettier" },
    go = { "gofumpt" },
    json = { "fixjson" },
    jsonc = { "fixjson" },
    dart = { "dart_format" },
  }
  if Config.has_project_file("pint.json") then formatters.php = { "pint" } end
  conform.setup({ notify_on_error = true, formatters_by_ft = formatters })
  local options = { async = true, lsp_format = "fallback" }
  vim.api.nvim_create_user_command(
    "Format",
    function() conform.format(options) end,
    {}
  )
end)

-- Linting ====================================================================
later(function()
  vim.pack.add({ "https://github.com/mfussenegger/nvim-lint" })
  local lint = require("lint")
  lint.linters_by_ft = {
    php = { "phpstan" },
    dockerfile = { "hadolint" },
    json = { "jsonlint" },
    jsonc = { "jsonlint" },
    typescript = { "eslint" },
    javascript = { "eslint" },
    lua = { "luacheck" },
    nix = { "nix" },
  }
  local trylint = function() lint.try_lint() end
  vim.api.nvim_create_user_command("Lint", trylint, {})
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = vim.api.nvim_create_augroup("custom-linting", { clear = true }),
    pattern = "*",
    desc = "Run linter",
    callback = trylint,
  })
end)

-- Snippets ===================================================================

-- Although 'mini.snippets' provides functionality to manage snippet files, it
-- deliberately doesn't come with those.
later(
  function() vim.pack.add({ "https://github.com/rafamadriz/friendly-snippets" }) end
)

-- Database integration =======================================================

later(function()
  vim.g.db_ui_use_nerd_fonts = 1
  vim.pack.add({
    "https://github.com/tpope/vim-dadbod",
    "https://github.com/kristijanhusak/vim-dadbod-ui",
    "https://github.com/kristijanhusak/vim-dadbod-completion",
  })
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "sql", "mysql", "plsql" },
    group = vim.api.nvim_create_augroup("dadbod-completion", { clear = true }),
    callback = function()
      vim.bo.omnifunc = "vim_dadbod_completion#omni"
      vim.b.minicompletion_config = { fallback_action = "<C-x><C-o>" }
      vim.bo.commentstring = "-- %s"
    end,
  })
end)

-- API testing with Hurl ======================================================
later(function()
  vim.pack.add({
    "https://github.com/MeanderingProgrammer/render-markdown.nvim",
    "https://github.com/jellydn/hurl.nvim",
  })
  require("hurl").setup()
end)

-- Debugging ==================================================================
later(function()
  vim.pack.add({
    "https://github.com/nvim-neotest/nvim-nio",
    "https://github.com/mfussenegger/nvim-dap",
    "https://github.com/rcarriga/nvim-dap-ui",
    "https://github.com/leoluz/nvim-dap-go",
  })

  local dap = require("dap")

  -- debug.php
  dap.adapters.xdebug = {
    type = "executable",
    command = "php-debug-adapter",
  }
  dap.configurations.php = {
    {
      type = "xdebug",
      request = "launch",
      name = "Listen for Xdebug",
      port = 9003,
    },
  }

  -- debug.golang
  if Config.has_project_file("go.mod") then require("dap-go").setup() end

  -- dap-ui
  local dapui = require("dapui")
  dap.listeners.after.event_initialized["dapui_config"] = dapui.open
  dap.listeners.before.event_terminated["dapui_config"] = dapui.close
  dap.listeners.before.event_exited["dapui_config"] = dapui.close
  dap.listeners.before.disconnect["dapui_config"] = dapui.close
  dapui.setup({
    layouts = {
      {
        elements = {
          { id = "scopes", size = 0.40 },
          { id = "stacks", size = 0.30 },
          { id = "breakpoints", size = 0.15 },
          { id = "watches", size = 0.15 },
        },
        position = "left",
        size = 40,
      },
      {
        elements = {
          { id = "repl", size = 1.0 },
        },
        position = "bottom",
        size = 12,
      },
    },
  })
end)

-- Testing ====================================================================
later(function()
  vim.pack.add({
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/andythigpen/nvim-coverage",
    "https://github.com/antoinemadec/FixCursorHold.nvim",
    "https://github.com/nvim-neotest/nvim-nio",
    "https://github.com/nvim-neotest/neotest",
    "https://github.com/fredrikaverpil/neotest-golang",
    "https://github.com/olimorris/neotest-phpunit",
    "https://github.com/nvim-neotest/neotest-jest",
    "https://github.com/thenbe/neotest-playwright",
    "https://github.com/sidlatau/neotest-dart",
  })

  -- coverage
  require("coverage").setup({
    commands = true,
    auto_reload = true,
  })

  local adapters = {}

  -- test.golang
  if Config.has_project_file("go.mod") then
    table.insert(
      adapters,
      require("neotest-golang")({
        dap_go_enabled = true,
        go_test_args = {
          "-v",
          "-race",
          "-count=1",
          "-timeout=60s",
          "-coverprofile=" .. vim.fn.getcwd() .. "/coverage.out",
        },
      })
    )
  end

  -- test.phpunit
  if Config.has_executable("php") then
    if Config.has_project_file("codeception.yml") then
      table.insert(adapters, require("neotest-codeception"))
      table.insert(adapters, require("neotest-codeception-gherkin"))
    else
      table.insert(adapters, require("neotest-phpunit"))
    end
  end

  -- test.dart test.flutter
  if Config.has_executable("flutter") then
    table.insert(
      adapters,
      require("neotest-dart")({
        command = "flutter",
        use_lsp = true,
      })
    )
  end

  if Config.has_executable("node") then
    -- test.jest
    table.insert(
      adapters,
      require("neotest-jest")({
        jestCommand = "npm run test -- --detectOpenHandles",
        jest_test_discovery = false,
      })
    )

    -- test.playwright
    table.insert(
      adapters,
      require("neotest-playwright").adapter({
        options = {
          persist_project_selection = true,
          enable_dynamic_test_discovery = true,
        },
      })
    )
  end

  -- neotest
  local neotest = require("neotest")
  neotest.setup({ adapters = adapters })

  -- extra keymaps
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "neotest-output" },
    group = vim.api.nvim_create_augroup(
      "neotest-output-keymaps",
      { clear = true }
    ),
    callback = function(ev)
      vim.keymap.set(
        "n",
        "q",
        "<Cmd>close<CR>",
        { desc = "Close panel", buffer = ev.buf }
      )
    end,
  })
end)
