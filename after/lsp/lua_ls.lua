return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".git", vim.uv.cwd() },
  on_attach = function(client, _) client.server_capabilities.completionProvider.triggerCharacters = { ".", ":" } end,
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path = vim.split(package.path, ";"),
      },
      diagnostics = {
        globals = { "vim", "describe", "it", "before_each", "after_each" },
        disable = { "need-check-nil" },
        workspaceDelay = -1,
      },
      workspace = {
        ignoreSubmodules = true,
      },
    },
  },
}
