return {
  cmd = { "gopls" },
  filetypes = { "go", "gotempl", "gowork", "gomod" },
  root_markers = { "go.mod", "go.work", ".git", vim.uv.cwd() },
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true,
      },
      ["ui.inlayhint.hints"] = {
        compositeLiteralFields = true,
        constantValues = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
}
