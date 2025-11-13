local add, later = MiniDeps.add, MiniDeps.later

local function has(exec) return vim.fn.executable(exec) == 1 end

local function hasprojectfile(filename)
  local path = vim.fn.getcwd() .. "/" .. filename
  local stat = vim.loop.fs_stat(path)
  return stat ~= nil
end

-- database
later(function()
  -- dadbod
  add("tpope/vim-dadbod")
  add("kristijanhusak/vim-dadbod-ui")
end)

-- code completion
later(function()
  -- blink
  add("rafamadriz/friendly-snippets")
  add("kristijanhusak/vim-dadbod-completion")
  add({
    source = "saghen/blink.cmp",
    checkout = "v1.7.0",
  })
  require("blink.cmp").setup({
    keymap = {
      preset = "default",
      ["<C-space>"] = {},
      ["<C-k>"] = { "show_documentation", "hide_documentation", "fallback" },
      ["<C-n>"] = { "select_next", "show", "fallback" },
    },
    cmdline = { enabled = false },
    completion = {
      accept = {
        auto_brackets = {
          enabled = true, -- integration with nvim-autopairs
        },
      },
    },
    sources = {
      default = function(_)
        if vim.bo.filetype == "sql" then return { "dadbod", "lsp", "snippets", "path", "buffer" } end

        local comments = { "comment", "line_comment", "block_comment" }
        local success, node = pcall(vim.treesitter.get_node)
        if success and node and vim.tbl_contains(comments, node:type()) then return { "buffer" } end

        return { "lsp", "snippets", "path", "buffer" }
      end,
      providers = {
        dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
      },
    },
  })
end)

-- formatter
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
  }

  if hasprojectfile("pint.json") then formatters.php = { "pint" } end

  conform.setup({
    notify_on_error = true,
    formatters_by_ft = formatters,
  })

  local options = {
    async = true,
    lsp_format = "fallback",
  }

  vim.keymap.set("n", "<leader>cf", function() conform.format(options) end, {
    desc = "[c]ode [f]ormat",
  })

  vim.api.nvim_create_user_command("Format", function() conform.format(options) end, {})
end)

-- linter
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

  vim.api.nvim_create_autocmd("BufWritePost", {
    group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
    callback = function() lint.try_lint() end,
  })

  vim.api.nvim_create_user_command("Lint", function() lint.try_lint() end, {})
end)

-- testing
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
  require("coverage").setup()

  local adapters = {}

  -- test.golang
  if has("go") then
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
  if has("php") then
    if hasprojectfile("codeception.yml") then
      table.insert(adapters, require("neotest-codeception"))
      table.insert(adapters, require("neotest-codeception-gherkin"))
    else
      table.insert(adapters, require("neotest-phpunit"))
    end
  end

  if has("node") then
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

  -- hurl
  later(function()
    add({
      source = "jellydn/hurl.nvim",
      depends = {
        "MeanderingProgrammer/render-markdown.nvim",
      },
    })
    require("hurl").setup()
  end)

  -- neotest
  local neotest = require("neotest")
  neotest.setup({
    adapters = adapters,
  })

  vim.keymap.set("n", "<leader>ta", function() neotest.run.attach() end, { desc = "[t]est [a]ttach" })
  vim.keymap.set("n", "<leader>tf", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "[t]est run [f]ile" })
  vim.keymap.set("n", "<leader>tA", function() neotest.run.run(vim.uv.cwd()) end, { desc = "[t]est [A]ll files" })
  vim.keymap.set("n", "<leader>tS", function() neotest.run.run({ suite = true }) end, { desc = "[t]est [S]uite" })
  vim.keymap.set("n", "<leader>tn", function() neotest.run.run() end, { desc = "[t]est [n]earest" })
  vim.keymap.set("n", "<leader>tl", function() neotest.run.run_last() end, { desc = "[t]est [l]ast" })
  vim.keymap.set("n", "<leader>ts", function() neotest.summary.toggle() end, { desc = "[t]est [s]ummary" })
  vim.keymap.set(
    "n",
    "<leader>to",
    function() neotest.output.open({ enter = true, auto_close = true }) end,
    { desc = "[t]est [o]utput" }
  )
  vim.keymap.set("n", "<leader>tO", function() neotest.output_panel.toggle() end, { desc = "[t]est [O]utput panel" })
  vim.keymap.set("n", "<leader>tt", function() neotest.run.stop() end, { desc = "[t]est [t]erminate" })
  vim.keymap.set(
    "n",
    "<leader>td",
    function() neotest.run.run({ suite = false, strategy = "dap" }) end,
    { desc = "[t]est [d]ebug nearest" }
  )
end)

-- lsp
later(function()
  add("mason-org/mason.nvim")
  add("nvim-flutter/flutter-tools.nvim")
  add("ccaglak/phptools.nvim")
  add("adibhanna/phprefactoring.nvim")

  require("mason").setup({})

  -- Disable the default keybinds
  for _, bind in ipairs({ "grn", "grd", "gra", "gri", "grr" }) do
    pcall(vim.keymap.del, "n", bind)
  end

  local pick = require("snacks").picker

  local keymaps = function(bufnr)
    vim.keymap.set({ "n", "x" }, "gra", vim.lsp.buf.code_action, { buffer = bufnr, desc = "[g]oto code [a]ction" })
    vim.keymap.set("n", "grd", pick.lsp_definitions, { buffer = bufnr, desc = "[g]oto [d]efinition" })
    vim.keymap.set("n", "grr", pick.lsp_references, { buffer = bufnr, desc = "[g]oto [r]eferences" })
    vim.keymap.set("n", "gri", pick.lsp_implementations, { buffer = bufnr, desc = "[g]oto [i]mplementations" })
    vim.keymap.set("n", "grD", pick.lsp_declarations, { buffer = bufnr, desc = "[g]oto [D]eclaration" })
    vim.keymap.set("n", "grn", vim.lsp.buf.rename, { buffer = bufnr, desc = "[r]e[n]ame" })
    vim.keymap.set("n", "grt", pick.lsp_type_definitions, { buffer = bufnr, desc = "[g]oto [t]ype definitions" })
    vim.keymap.set("n", "gO", pick.lsp_symbols, { buffer = bufnr, desc = "[d]ocument [s]ymbols" })
    vim.keymap.set("n", "gW", pick.lsp_workspace_symbols, { buffer = bufnr, desc = "[w]orkspace [s]ymbols" })
  end

  vim.diagnostic.config({
    severity_sort = true,
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "󰅚 ",
        [vim.diagnostic.severity.WARN] = "󰀪 ",
        [vim.diagnostic.severity.INFO] = "󰋽 ",
        [vim.diagnostic.severity.HINT] = "󰌶 ",
      },
    },
    virtual_text = {
      current_line = true,
    },
    float = {
      border = "rounded",
    },
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("nvim_lsp_attach", { clear = true }),
    callback = function(event) keymaps(event.buf) end,
  })

  local capabilities = require("blink.cmp").get_lsp_capabilities()
  vim.lsp.config("*", { capabilities = capabilities })

  -- lang.lua
  vim.lsp.enable("lua_ls")

  -- lang.golang
  if has("go") then vim.lsp.enable("gopls") end

  -- lang.php
  if has("php") and has("node") then
    vim.lsp.enable("intelephense")

    if hasprojectfile("composer.json") then
      require("phptools").setup()
      require("phprefactoring").setup()
    end
  end

  -- lang.javascript
  if has("node") then
    -- lang.typescript
    vim.lsp.enable("vtsls")

    -- lang.cucumber
    vim.lsp.enable("cucumberls")

    -- lang.html lang.css
    vim.lsp.enable({ "superhtml", "cssls", "emmetls" })
  end

  -- lang.bash
  vim.lsp.enable("bashls")

  -- lang.nix
  vim.lsp.enable("nixd")

  -- lang.qml
  vim.lsp.enable("qmlls")

  -- lang.flutter
  if has("flutter") then
    require("flutter-tools").setup({
      flutter_lookup_cmd = "mise where flutter",
      lsp = {
        capabilities = capabilities,
      },
    })
  end

  -- lang.openapi
  vim.lsp.enable("vacuum")
end)

-- debugger
later(function()
  add("nvim-neotest/nvim-nio")
  add("mfussenegger/nvim-dap")
  add("leoluz/nvim-dap-go")
  add("rcarriga/nvim-dap-ui")

  -- dap
  local dap = require("dap")
  vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
  vim.keymap.set("n", "<F1>", dap.step_into, { desc = "Debug: Step Into" })
  vim.keymap.set("n", "<F2>", dap.step_over, { desc = "Debug: Step Over" })
  vim.keymap.set("n", "<F3>", dap.step_out, { desc = "Debug: Step Out" })
  vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "[b]reakpoint toggle" })
  vim.keymap.set(
    "n",
    "<leader>B",
    function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
    { desc = "[B]reakpoint condition" }
  )

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
  if has("go") then require("dap-go").setup() end

  -- dap-ui
  local dapui = require("dapui")
  dap.listeners.after.event_initialized["dapui_config"] = dapui.open
  dap.listeners.before.event_terminated["dapui_config"] = dapui.close
  dap.listeners.before.event_exited["dapui_config"] = dapui.close
  dap.listeners.before.disconnect["dapui_config"] = dapui.close
  dapui.setup()
end)

-- Start, Stop, Restart, Log commands {{{
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("nvim_lsp_attach_autocmds", { clear = true }),
  callback = function(_)
    vim.api.nvim_create_user_command(
      "LspStart",
      function() vim.cmd.e() end,
      { desc = "Starts LSP clients in the current buffer" }
    )

    vim.api.nvim_create_user_command("LspStop", function(opts)
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        if opts.args == "" or opts.args == client.name then
          client:stop(true)
          vim.notify(client.name .. ": stopped")
        end
      end
    end, {
      desc = "Stop all LSP clients or a specific client attached to the current buffer.",
      nargs = "?",
      complete = function(_, _, _)
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        local client_names = {}
        for _, client in ipairs(clients) do
          table.insert(client_names, client.name)
        end
        return client_names
      end,
    })

    vim.api.nvim_create_user_command("LspRestart", function()
      local detach_clients = {}
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        client:stop(true)
        if vim.tbl_count(client.attached_buffers) > 0 then
          detach_clients[client.name] = { client, vim.lsp.get_buffers_by_client_id(client.id) }
        end
      end
      local timer = vim.uv.new_timer()
      if not timer then return vim.notify("Servers are stopped but havent been restarted") end
      timer:start(
        100,
        50,
        vim.schedule_wrap(function()
          for name, client in pairs(detach_clients) do
            local client_id = vim.lsp.start(client[1].config, { attach = false })
            if client_id then
              for _, buf in ipairs(client[2]) do
                vim.lsp.buf_attach_client(buf, client_id)
              end
              vim.notify(name .. ": restarted")
            end
            detach_clients[name] = nil
          end
          if next(detach_clients) == nil and not timer:is_closing() then timer:close() end
        end)
      )
    end, {
      desc = "Restart all the language client(s) attached to the current buffer",
    })

    vim.api.nvim_create_user_command("LspLog", function() vim.cmd.vsplit(vim.lsp.log.get_filename()) end, {
      desc = "Get all the lsp logs",
    })
  end,
})

vim.api.nvim_create_user_command("LspInfo", function() vim.cmd("silent checkhealth vim.lsp") end, {
  desc = "Get all the information about all LSP attached",
})

later(function()
  if hasprojectfile("composer.lock") then
    local phputils = require("phputils")
    vim.api.nvim_create_user_command("PhpFindFQCN", phputils.fqcn_navigate, {})
    vim.api.nvim_create_user_command("CopyPHPClassFQCN", phputils.copy_fqcn, {})
    vim.api.nvim_create_user_command("CopyPHPNearMemberFQCN", phputils.copy_fqcn_with_near_member, {})
  end
end)
