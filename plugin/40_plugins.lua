local now, now_if_args, later = Config.now, Config.now_if_args, Config.later

--- theme
now(function()
  vim.pack.add({ "https://github.com/navarasu/onedark.nvim" })
  require("onedark").setup({})
  require("onedark").load()
end)

-- treesitter
now_if_args(function()
  local ts_update = function() vim.cmd("TSUpdate") end
  Config.on_packchanged("nvim-treesitter", { "update" }, ts_update, ":TSUpdate")

  vim.pack.add({
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  })

  -- blade
  vim.filetype.add({
    pattern = {
      [".*%.blade%.php"] = "blade",
    },
  })

  local languages = {
    "bash",
    "blade",
    "comment",
    "css",
    "dart",
    "diff",
    "go",
    "gomod",
    "gosum",
    "gotmpl",
    "gowork",
    "html",
    "hurl",
    "ini",
    "javascript",
    "json",
    "latex",
    "lua",
    "markdown_inline",
    "markdown",
    "nix",
    "php",
    "regex",
    "scss",
    "sql",
    "tmux",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "vue",
    "yaml",
    "zsh",
  }
  vim.treesitter.language.register("sql", "mysql")

  require("nvim-treesitter").install(languages)

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("enable-treesitter", { clear = true }),
    callback = function(ev)
      pcall(vim.treesitter.start, ev.buf)
      vim.wo[0][0].foldmethod = "expr"
      vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })
end)

-- file picking and exploring
now_if_args(function()
  -- snacks
  vim.pack.add({ "https://github.com/folke/snacks.nvim" })
  local snacks = require("snacks")
  snacks.setup({
    image = { enabled = true },
    input = { enabled = true },
    words = { enabled = true },
    explorer = {
      enabled = true,
      replace_netrw = false,
      trash = false,
    },
    picker = {
      ui_select = true,
      sources = {
        recent = {
          filter = { cwd = true },
        },
        explorer = {
          border = false,
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
  vim.ui.select = snacks.picker.select
  vim.g.snacks_animate = false
  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesActionRename",
    callback = function(event)
      Snacks.rename.on_rename_file(event.data.from, event.data.to)
    end,
  })

  local get_explorer_win = function()
    local explorer_win = nil
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].filetype
      if ft == "snacks_picker_list" then
        explorer_win = win
        break
      end
    end
    if vim.api.nvim_get_current_win() ~= explorer_win and explorer_win then
      return explorer_win
    end
    return nil
  end

  vim.api.nvim_create_user_command("SnacksExplorerFocus", function()
    local explorer_win = get_explorer_win()
    if explorer_win then
      vim.api.nvim_set_current_win(explorer_win)
      return
    end
    Snacks.explorer.reveal()
  end, {})

  -- disable completion on inputs
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "snacks_picker_input", "snacks_input" },
    group = vim.api.nvim_create_augroup(
      "disable-mini-completion",
      { clear = true }
    ),
    callback = function() vim.b.minicompletion_disable = true end,
  })
end)

-- markdown
later(function()
  vim.pack.add({
    "https://github.com/MeanderingProgrammer/render-markdown.nvim",
  })
  require("render-markdown").setup()
end)
