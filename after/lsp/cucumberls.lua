return {
  cmd = { "cucumber-language-server", "--stdio" },
  filetypes = { "cucumber" },
  root_markers = { ".git", vim.uv.cwd() },
  settings = {
    cucumber = {
      features = {
        "tests/**/*.feature",
      },
      glue = {
        -- Behat
        "tests/**/*.php",
      },
    },
  },
}
