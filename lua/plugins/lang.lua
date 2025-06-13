return {
  {
    "ccaglak/phptools.nvim",
    event = "VeryLazy",
    ft = "php",
    opts = true,
  },
  {
    "nvim-flutter/flutter-tools.nvim",
    depedencies = { "blink.cmp" },
    event = "VeryLazy",
    opts = function(_, opts)
      opts.flutter_lookup_cmd = "mise where flutter"
      opts.lsp = {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      }
    end,
  },
}
