return {
  {
    "echasnovski/mini.splitjoin",
    opts = function()
      local plugin = require("mini.splitjoin")

      return {
        mappings = {
          toggle = "ts",
        },
        split = {
          hooks_pre = {},
          hooks_post = {
            plugin.gen_hook.add_trailing_separator({}),
          },
        },
        join = {
          hooks_pre = {},
          hooks_post = {
            plugin.gen_hook.del_trailing_separator({}),
          },
        },
      }
    end,
  },
  {
    "echasnovski/mini.move",
    opts = {
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
    },
  },
}
