local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

--- theme
now(function()
  add("ellisonleao/gruvbox.nvim")
  require("gruvbox").setup({
    dim_inactive = false,
    contrast = "hard",
  })
  vim.cmd.colorscheme("gruvbox")
end)

now(function()
  add("nvim-lua/plenary.nvim")
  add("MunifTanjim/nui.nvim")
end)

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
    input = { enabled = true },
    explorer = {
      replace_netrw = false,
    },
    picker = {
      ui_select = true,
      formatters = {
        file = { truncate = 60 },
      },
      layout = {
        cycle = false,
        preset = "ivy",
      },
      sources = {
        recent = {
          filter = { cwd = true },
        },
        explorer = {
          ignored = true,
          hidden = true,
          exclude = { ".git" },
        },
        files = {
          hidden = true,
          include = { ".env" },
        },
      },
    },
  })

  -- explorer
  vim.keymap.set("n", "<leader>e", function() snacks.explorer() end, { desc = "[e]xplorer toggle" })

  -- picker
  local pick = snacks.picker
  vim.keymap.set(
    "n",
    "<leader><space>",
    function()
      pick.smart({
        formatters = { file = { truncate = vim.o.columns } },
        layout = { preview = false },
      })
    end,
    { desc = "smart picker" }
  )
  vim.keymap.set("n", "<leader>/", pick.grep, { desc = "pick grep" })
  vim.keymap.set("n", "<leader>.", pick.recent, { desc = "pick recent" })
  vim.keymap.set("n", "<leader>pb", pick.buffers, { desc = "[p]ick [b]uffers" })
  vim.keymap.set(
    "n",
    "<leader>pf",
    function()
      pick.files({
        formatters = { file = { truncate = vim.o.columns } },
        layout = { preview = false },
      })
    end,
    { desc = "[p]ick [f]iles" }
  )

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

-- statusline
later(function()
  add("nvim-lualine/lualine.nvim")
  add("linrongbin16/lsp-progress.nvim")

  local lualine_require = require("lualine_require")
  lualine_require.require = require
  local lualine = require("lualine")
  local lsp_progress = require("lsp-progress")
  lsp_progress.setup()

  local lsp_status = function() return lsp_progress.progress() end

  vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = "lualine_augroup",
    pattern = "LspProgressStatusUpdated",
    callback = lualine.refresh,
  })

  lualine.setup({
    options = {
      theme = "gruvbox",
      globalstatus = true,
      section_separators = "",
      component_separators = "",
    },
    sections = {
      lualine_c = { "%<%f %h%m%r", lsp_status },
    },
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
      "hurl",
    },
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
  })
end)

-- markdown
later(function()
  add("MeanderingProgrammer/render-markdown.nvim")
  require("render-markdown").setup()
end)
