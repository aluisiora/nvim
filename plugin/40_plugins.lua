local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

--- theme
now(function()
  add("AlexvZyl/nordic.nvim")
  vim.cmd.colorscheme("nordic")
end)

now(function()
  add("nvim-lua/plenary.nvim")
  add("MunifTanjim/nui.nvim")
end)

-- treesitter
now(function()
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

  local ts = require("nvim-treesitter")
  ts.setup()
  ts.install({
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
  })
  vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  vim.treesitter.language.register("sql", "mysql")
end)

-- folke
now(function()
  add("folke/snacks.nvim")

  -- snacks
  vim.g.snacks_animate = false
  local snacks = require("snacks")
  snacks.setup({
    bigfile = { enabled = true },
    words = { enabled = true },
    quickfile = { enabled = true },
    image = { enabled = true },
    input = { enabled = true },
    indent = {
      enabled = true,
      only_scope = true,
      only_current = true,
    },
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

  -- words
  local words = snacks.words
  vim.keymap.set("n", "]r", function() words.jump(1) end, { desc = "next reference" })
  vim.keymap.set("n", "[r", function() words.jump(-1) end, { desc = "previous reference" })

  -- bufdelete
  vim.keymap.set("n", "<leader>bd", function() snacks.bufdelete() end, { desc = "[b]uffer [d]elete" })
  -- rename
  vim.keymap.set("n", "<leader>rf", snacks.rename.rename_file, { desc = "[r]ename [f]ile" })
  vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "netrw" },
    group = vim.api.nvim_create_augroup("NetrwOnRename", { clear = true }),
    callback = function()
      vim.keymap.set("n", "R", function()
        local original_file_path = vim.b.netrw_curdir .. "/" .. vim.fn["netrw#Call"]("NetrwGetWord")

        vim.ui.input({ prompt = "Move/rename to:", default = original_file_path }, function(target_file_path)
          if target_file_path and target_file_path ~= "" then
            local file_exists = vim.uv.fs_access(target_file_path, "W")

            if not file_exists then
              vim.uv.fs_rename(original_file_path, target_file_path)

              snacks.rename.on_rename_file(original_file_path, target_file_path)
            else
              vim.notify("File '" .. target_file_path .. "' already exists! Skipping...", vim.log.levels.ERROR)
            end

            -- Refresh netrw
            vim.cmd(":Ex " .. vim.b.netrw_curdir)
          end
        end)
      end, { remap = true, buffer = true })
    end,
  })
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
      theme = "nordic",
      globalstatus = true,
      section_separators = "",
      component_separators = "",
    },
    sections = {
      lualine_c = { "%<%f %h%m%r", lsp_status },
    },
  })
end)

-- comments
later(function()
  add("numToStr/Comment.nvim")
  require("Comment").setup()
end)

-- undotree
later(function() add("mbbill/undotree") end)

-- markdown
later(function()
  add("MeanderingProgrammer/render-markdown.nvim")
  require("render-markdown").setup()
end)

later(function()
  local snacks = require("snacks")
  snacks.input.enable()
  vim.ui.select = snacks.picker.select
end)
