local start_time = vim.loop.hrtime()
local vim_enter_time = 0

local function calcRuntime()
  local end_time = vim.loop.hrtime()
  return (end_time - start_time) / 1e6 -- Convert from nanoseconds to milliseconds
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function() vim_enter_time = calcRuntime() end,
})

-- editor
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.termguicolors = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = false
vim.o.cursorline = true
vim.o.scrolloff = 12
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.splitkeep = "cursor"
vim.o.hlsearch = true
vim.o.autoindent = true
vim.o.smartindent = false
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.swapfile = false
vim.o.backup = false
vim.o.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.o.undofile = true
vim.o.encoding = "utf-8"
vim.o.fileencoding = "utf-8"
vim.o.signcolumn = "yes"
vim.o.showmode = false
vim.o.background = "dark"

-- functions
local function augroup(name) return vim.api.nvim_create_augroup("nvim_" .. name, { clear = true }) end
local function bufferpath() return vim.fn.expand("%:~:.") end
local function has(exec) return vim.fn.executable(exec) == 1 end
local function hasprojectfile(filename)
  local path = vim.fn.getcwd() .. "/" .. filename
  local stat = vim.loop.fs_stat(path)
  return stat ~= nil
end

-- keymaps
vim.keymap.set("n", "<leader>N", vim.cmd.Ex, { desc = "Netwr" })
vim.keymap.set("n", "x", '"_x')
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open buffer diagnostic [q]uickfix list" })
vim.keymap.set("n", "<leader>Q", vim.diagnostic.setqflist, { desc = "Open project diagnostic [Q]uickfix list" })
vim.keymap.set("n", "<leader>D", vim.diagnostic.open_float, { desc = "[D]iagnostic message" })

-- mini
local path_package = vim.fn.stdpath("data") .. "/site"
local mini_path = path_package .. "/pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/echasnovski/mini.nvim",
    mini_path,
  }
  vim.fn.system(clone_cmd)
  vim.cmd("packadd mini.nvim | helptags ALL")
end

-- mini.deps
local minideps = require("mini.deps")
minideps.setup({ path = { package = path_package } })

local add, now, later = minideps.add, minideps.now, minideps.later

--- theme
now(function()
  add("ellisonleao/gruvbox.nvim")
  require("gruvbox").setup()
  vim.cmd.colorscheme("gruvbox")
end)

now(function() add("nvim-lua/plenary.nvim") end)

-- folke
now(function()
  add("folke/snacks.nvim")

  -- snacks
  vim.g.snacks_animate = false
  local snacks = require("snacks")
  snacks.setup({
    bigfile = { enabled = true },
    indent = { enabled = true },
    words = { enabled = true },
    quickfile = { enabled = true },
    image = { enabled = true },
    picker = {
      ui_select = true,
      layout = {
        cycle = false,
        preset = "ivy",
      },
      sources = {
        files = {
          include = { ".env" },
        },
      },
    },
  })

  -- picker
  local pick = snacks.picker
  vim.keymap.set("n", "<leader><space>", pick.smart, { desc = "smart picker" })
  vim.keymap.set("n", "<leader>/", pick.grep, { desc = "pick grep" })
  vim.keymap.set("n", "<leader>.", pick.recent, { desc = "pick recent" })
  vim.keymap.set("n", "<leader>pb", pick.buffers, { desc = "[p]ick [b]uffers" })
  vim.keymap.set("n", "<leader>pf", pick.files, { desc = "[p]ick [f]iles" })

  vim.keymap.set("n", "<leader>pj", pick.jumps, { desc = "[p]ick [j]umps" })
  vim.keymap.set("n", "<leader>pk", pick.keymaps, { desc = "[p]ick [k]eymaps" })
  vim.keymap.set("n", "<leader>pp", pick.pickers, { desc = "[p]ick [p]ickers" })

  vim.keymap.set("n", "<leader>pd", pick.diagnostics_buffer, { desc = "[p]ick buffer [d]iagnostic" })
  vim.keymap.set("n", "<leader>pD", pick.diagnostics, { desc = "[p]ick all [D]iagnostic" })
  vim.keymap.set("n", "<leader>pgb", pick.git_branches, { desc = "[p]ick [g]it [b]ranches" })
  vim.keymap.set("n", "<leader>pgh", pick.git_diff, { desc = "[p]ick [g]it [h]unks" })
  vim.keymap.set("n", "<leader>pgl", pick.git_log_file, { desc = "[p]ick [g]it buffer [l]og" })
  vim.keymap.set("n", "<leader>pgL", pick.git_log, { desc = "[p]ick [g]it all [L]og" })
  vim.keymap.set("n", "<leader>pgs", pick.git_status, { desc = "[p]ick [g]it [s]tatus" })

  -- bufdelete
  vim.keymap.set("n", "<leader>bd", function() snacks.bufdelete() end, { desc = "[b]uffer [d]elete" })
  -- rename
  vim.keymap.set("n", "<leader>rf", snacks.rename.rename_file, { desc = "[r]ename [f]ile" })

  -- words
  local words = snacks.words
  vim.keymap.set("n", "]r", function() words.jump(1) end, { desc = "next reference" })
  vim.keymap.set("n", "[r", function() words.jump(-1) end, { desc = "previous reference" })
end)

-- mini.icons
later(require("mini.icons").setup)

-- mini.git
later(require("mini.git").setup)

-- mini.diff
later(function()
  local diff = require("mini.diff")
  diff.setup()

  vim.keymap.set("n", "<leader>hp", diff.toggle_overlay, { desc = "[h]unk [p]review" })
end)

-- statusline
later(function()
  add("nvim-lualine/lualine.nvim")

  local lualine_require = require("lualine_require")
  lualine_require.require = require

  require("lualine").setup({
    options = {
      theme = "gruvbox",
      globalstatus = true,
      section_separators = "",
      component_separators = "",
    },
    sections = {
      lualine_c = { "%<%f %h%m%r" },
    },
  })
end)

-- mini.ai
later(require("mini.ai").setup)

-- mini.surround
later(require("mini.surround").setup)

-- mini.splitjoin
later(function()
  local splitjoin = require("mini.splitjoin")
  splitjoin.setup({
    mappings = {
      toggle = "ts",
    },
    split = {
      hooks_pre = {},
      hooks_post = {
        splitjoin.gen_hook.add_trailing_separator({}),
      },
    },
    join = {
      hooks_pre = {},
      hooks_post = {
        splitjoin.gen_hook.del_trailing_separator({}),
      },
    },
  })
end)

-- mini.move
later(
  function()
    require("mini.move").setup({
      mappings = {
        left = "H",
        right = "L",
        down = "J",
        up = "K",
        line_left = "<C-S-h>",
        line_right = "<C-S-l>",
        line_down = "<C-S-j>",
        line_up = "<C-S-k>",
      },
      options = {
        reindent_linewise = true,
      },
    })
  end
)

-- mini.files
later(function()
  local files = require("mini.files")
  files.setup({
    options = {
      use_as_default_explorer = false,
    },
  })

  vim.keymap.set(
    "n",
    "<leader>n",
    function() files.open(vim.api.nvim_buf_get_name(0)) end,
    { desc = "[n]avigate files" }
  )

  local snacks = require("snacks")
  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesActionRename",
    callback = function(event) snacks.rename.on_rename_file(event.data.from, event.data.to) end,
  })
end)

-- autopairs
later(function()
  add("windwp/nvim-autopairs")
  require("nvim-autopairs").setup()
end)

-- comments
later(function()
  add("numToStr/Comment.nvim")
  require("Comment").setup()
end)

-- undotree
later(function() add("mbbill/undotree") end)

-- treesitter
later(function()
  add({
    source = "nvim-treesitter/nvim-treesitter",
    hooks = {
      post_checkout = function() vim.cmd("TSUpdate") end,
    },
  })

  -- blade
  vim.filetype.add({
    pattern = {
      [".*%.blade%.php"] = "blade",
    },
  })

  require("nvim-treesitter.configs").setup({
    ensure_installed = {
      "lua",
      "sql",
      "html",
      "css",
      "javascript",
      "php",
      "blade",
      "diff",
      "vim",
      "vimdoc",
      "json",
      "go",
      "gowork",
      "gomod",
      "gosum",
      "gotmpl",
      "comment",
    },
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
  })
end)

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
    checkout = "v1.4.1",
  })
  require("blink.cmp").setup({
    keymap = {
      preset = "default",
      ["<C-space>"] = {},
      ["<C-k>"] = { "show_documentation", "hide_documentation", "fallback" },
      ["<C-n>"] = { "select_next", "show", "fallback" },
    },
    cmdline = { enabled = false },
    comletion = {
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
    html = { "prettier" },
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
    group = augroup("lint"),
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
  add("j-hui/fidget.nvim")
  add("nvim-flutter/flutter-tools.nvim")
  add("ccaglak/phptools.nvim")
  add({
    source = "adibhanna/phprefactoring.nvim",
    depends = { "MunifTanjim/nui.nvim" },
  })

  require("mason").setup({})
  require("fidget").setup({
    notification = {
      window = {
        winblend = 0,
      },
    },
  })

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
    group = augroup("lsp-attach"),
    callback = function(event) keymaps(event.buf) end,
  })

  local capabilities = require("blink.cmp").get_lsp_capabilities()
  vim.lsp.config("*", { capabilities = capabilities })

  -- lang.lua
  vim.lsp.enable("lua_ls")

  -- lang.golang
  if has("go") then vim.lsp.enable("gopls") end

  if has("php") and has("node") then
    -- lang.php
    vim.lsp.enable("intelephense")

    if hasprojectfile("composer.json") then
      require("phptools").setup()
      require("phprefactoring").setup()
    end
  end

  if has("node") then
    -- lang.javascript
    -- lang.typescript
    vim.lsp.enable("vtsls")

    -- lang.cucumber
    vim.lsp.enable("cucumberls")
  end

  -- lang.bash
  vim.lsp.enable("bashls")

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
  vim.filetype.add({
    pattern = {
      ["openapi.*%.ya?ml"] = "yaml.openapi",
      ["openapi.*%.json"] = "json.openapi",
    },
  })
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

-- autocmds
later(function()
  -- Highlight when yanking (copying) text
  vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = augroup("highlight_yank"),
    callback = function() vim.highlight.on_yank() end,
  })
end)

-- commands
later(function()
  vim.api.nvim_create_user_command("CopyAbsolutePath", function()
    local path = vim.fn.expand("%:p")
    vim.fn.setreg("+", path)
    vim.notify('Copied "' .. path .. '" to the clipboard')
  end, {})

  vim.api.nvim_create_user_command("CopyRelativePath", function()
    local path = bufferpath()
    vim.fn.setreg("+", path)
    vim.notify('Copied "' .. path .. '" to the clipboard')
  end, {})

  if hasprojectfile("composer.lock") then
    local phputils = require("phputils")
    vim.api.nvim_create_user_command("PhpFindFQCN", phputils.fqcn_navigate, {})
    vim.api.nvim_create_user_command("CopyPHPClassFQCN", phputils.copy_fqcn, {})
    vim.api.nvim_create_user_command("CopyPHPNearMemberFQCN", phputils.copy_fqcn_with_near_member, {})
  end
end)

-- Start, Stop, Restart, Log commands {{{
vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup("lsp-attach-autocmds"),
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
-- }}}

later(function()
  local snacks = require("snacks")
  vim.ui.select = snacks.picker.select
end)

-- load report
later(function()
  local duration = calcRuntime()
  print(string.format("Neovim loaded in %.2f ms. Plugins loaded in %.2f ms.", vim_enter_time, duration))
end)
