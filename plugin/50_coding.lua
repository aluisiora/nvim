local add, later = MiniDeps.add, MiniDeps.later
local now_if_args = _G.Config.now_if_args

-- Language servers ===========================================================

-- Mason
now_if_args(function()
  add("mason-org/mason.nvim")
  require("mason").setup({})
end)

-- LSPs
later(function()
  add("j-hui/fidget.nvim")
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
  add("nvim-flutter/flutter-tools.nvim")
  if _G.has_executable("flutter") then
    require("flutter-tools").setup({
      flutter_lookup_cmd = "mise where flutter",
    })
  end
end)

-- Formatting =================================================================
later(function()
  add("stevearc/conform.nvim")
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
  if _G.has_project_file("pint.json") then formatters.php = { "pint" } end
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
  add("mfussenegger/nvim-lint")
  local lint = require("lint")
  lint.linters_by_ft = {
    php = { "phpstan" },
    dockerfile = { "hadolint" },
    json = { "jsonlint" },
    jsonc = { "jsonlint" },
    typescript = { "eslint" },
    javascript = { "eslint" },
    lua = { "luacheck" },
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
later(function() add("rafamadriz/friendly-snippets") end)

-- Database integration =======================================================

later(function()
  vim.g.db_ui_use_nerd_fonts = 1
  add("tpope/vim-dadbod")
  add("kristijanhusak/vim-dadbod-ui")
  add("kristijanhusak/vim-dadbod-completion")
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
  add({
    source = "jellydn/hurl.nvim",
    depends = {
      "MeanderingProgrammer/render-markdown.nvim",
    },
  })
  require("hurl").setup()
end)

-- Debugging ==================================================================
later(function()
  add("nvim-neotest/nvim-nio")
  add("mfussenegger/nvim-dap")
  add("leoluz/nvim-dap-go")
  add("rcarriga/nvim-dap-ui")

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
      port = 9000,
    },
  }

  -- debug.golang
  if _G.has_project_file("go.mod") then require("dap-go").setup() end

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
  add("andythigpen/nvim-coverage")
  add("antoinemadec/FixCursorHold.nvim")
  add("nvim-neotest/nvim-nio")
  add("nvim-neotest/neotest")
  add("fredrikaverpil/neotest-golang")
  add("olimorris/neotest-phpunit")
  add("nvim-neotest/neotest-jest")
  add("thenbe/neotest-playwright")

  -- coverage
  require("coverage").setup({
    commands = true,
    auto_reload = true,
  })

  local adapters = {}

  -- test.golang
  if _G.has_project_file("go.mod") then
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
  if _G.has_executable("php") then
    if _G.has_project_file("codeception.yml") then
      table.insert(adapters, require("neotest-codeception"))
      table.insert(adapters, require("neotest-codeception-gherkin"))
    else
      table.insert(adapters, require("neotest-phpunit"))
    end
  end

  if _G.has_executable("node") then
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
