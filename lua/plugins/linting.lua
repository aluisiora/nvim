return {
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.php = { "phpstan" }
      opts.linters_by_ft.json = { "jsonlint" }
      opts.linters_by_ft.jsonc = { "jsonlint" }
    end,
  },
}
