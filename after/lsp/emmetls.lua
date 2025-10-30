return {
  cmd = { "emmet-language-server", "--stdio" },
  filetypes = {
    "css",
    "eruby",
    "html",
    "htmldjango",
    "javascriptreact",
    "less",
    "pug",
    "sass",
    "scss",
    "typescriptreact",
    "htmlangular",
  },
  root_markers = { "package.json", ".git", vim.uv.cwd() },
  single_file_support = true,
}
