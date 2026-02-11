local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local now_if_args = _G.Config.now_if_args

--- theme
now(function()
  add({ source = "catppuccin/nvim", name = "catppuccin" })
  require("catppuccin").setup({ flavour = "mocha" })
  vim.cmd.colorscheme("catppuccin")
end)

now(function()
  add("nvim-lua/plenary.nvim")
  add("MunifTanjim/nui.nvim")
end)

-- treesitter
now_if_args(function()
  add({
    source = "nvim-treesitter/nvim-treesitter",
    hooks = { post_checkout = function() vim.cmd("TSUpdate") end },
  })
  add("nvim-treesitter/nvim-treesitter-textobjects")

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
    "vim",
    "vimdoc",
    "markdown",
    "sql",
    "html",
    "css",
    "javascript",
    "php",
    "blade",
    "diff",
    "json",
    "go",
    "gowork",
    "gomod",
    "gosum",
    "gotmpl",
    "comment",
    "hurl",
  })
  vim.treesitter.language.register("sql", "mysql")
end)

-- file picking and exploring
now_if_args(function()
  -- snacks
  add("folke/snacks.nvim")
  local snacks = require("snacks")
  snacks.setup({
    image = { enabled = true },
    input = { enabled = true },
    words = { enabled = true },
    explorer = {
      replace_netrw = false,
    },
    picker = {
      ui_select = true,
      layout = { cycle = false, preset = "ivy" },
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
  vim.ui.select = snacks.picker.select
  vim.g.snacks_animate = false
  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesActionRename",
    callback = function(event)
      Snacks.rename.on_rename_file(event.data.from, event.data.to)
    end,
  })

  -- fff
  add({
    source = "dmtrKovalenko/fff.nvim",
    hooks = { post_checkout = function() require("fff.download").download_or_build_binary() end },
  })
  vim.g.fff = {
    prompt = "󰄾 ",
    lazy_sync = true,
    layout = { prompt_position = "top" },
    preview = { enabled = false },
    git = { status_text_color = true },
  }

  -- fff & snacks
  add("madmaxieee/fff-snacks.nvim")
  require("fff-snacks").setup()
end)

-- undotree
later(function() add("mbbill/undotree") end)

-- markdown
later(function()
  add("MeanderingProgrammer/render-markdown.nvim")
  require("render-markdown").setup()
end)
