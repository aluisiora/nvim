local homedir = vim.fn.expand("~")

return {
  cmd = { "intelephense", "--stdio" },
  filetypes = { "php" },
  root_markers = { "composer.json", ".git" },
  init_options = {
    globalStoragePath = homedir .. "/.config/intelephense",
    licenceKey = homedir .. "/.config/intelephense/licence.txt",
  },
  settings = {
    intelephense = {
      maxMemory = 4096,
      format = {
        enable = false,
      },
      files = {
        exclude = {
          "**/.git/**",
          "**/.svn/**",
          "**/.hg/**",
          "**/.direnv/**",
          "**/CVS/**",
          "**/.DS_Store/**",
          "**/.phpstan/**",
          "**/libs/**",
          "**/node_modules/**",
          "**/bower_components/**",
          "**/vendor/**/{Tests,tests}/**",
          "**/.history/**",
          "**/vendor/**/vendor/**",
        },
      },
    },
  },
}
