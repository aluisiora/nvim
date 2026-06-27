local later, ai_mode = Config.later, Config.ai_mode

-- claude
later(function()
  local magenta_build = function(data)
    vim.system({ "npm", "run", "build" }, { cwd = data.path }):wait()
  end
  Config.on_packchanged(
    "magenta.nvim",
    { "update" },
    magenta_build,
    "build magenta"
  )
  vim.pack.add({ "https://github.com/dlants/magenta.nvim" })

  if ai_mode == "claude" then
    require("magenta").setup({
      picker = "snacks",
      profiles = {
        {
          name = "claude-sonnet",
          provider = "anthropic",
          model = "claude-sonnet-4-6",
          fastModel = "claude-haiku-4-5",
          apiKeyEnvVar = "ANTHROPIC_API_KEY",
        },
      },
    })
  end
end)

-- antigravity
later(function()
  vim.pack.add({ "https://www.github.com/HakonHarnes/img-clip.nvim" })
  vim.pack.add({
    {
      src = "https://www.github.com/olimorris/codecompanion.nvim",
      version = vim.version.range("^19.0.0"),
    },
  })

  if ai_mode == "codecompanion" then
    require("img-clip").setup({
      filetypes = {
        codecompanion = {
          prompt_for_file_name = false,
          template = "[Image]($FILE_PATH)",
          use_absolute_path = true,
        },
      },
    })
    require("codecompanion").setup()
  end
end)
