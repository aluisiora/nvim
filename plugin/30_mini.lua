local later = MiniDeps.later

-- mini.icons
later(require("mini.icons").setup)

-- mini.hipatterns
later(require("mini.hipatterns").setup)

-- mini.git
later(require("mini.git").setup)

-- mini.diff
later(function()
  local diff = require("mini.diff")
  diff.setup()

  vim.keymap.set("n", "<leader>hp", diff.toggle_overlay, { desc = "[h]unk [p]review" })
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
