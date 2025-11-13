vim.filetype.add({
  pattern = {
    ["openapi.*%.ya?ml"] = "yaml.openapi",
    ["openapi.*%.json"] = "json.openapi",
  },
})

return {
  cmd = { "vacuum", "language-server" },
  filetypes = { "yaml.openapi", "json.openapi" },
  single_file_support = true,
  root_markers = { ".git", vim.uv.cwd() },
}
