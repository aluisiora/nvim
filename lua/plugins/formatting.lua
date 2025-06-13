return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    opts.formatters_by_ft.php = { "php_cs_fixer" }
    opts.formatters_by_ft.json = { "fixjson" }
    opts.formatters_by_ft.jsonc = { "fixjson" }
  end,
}
