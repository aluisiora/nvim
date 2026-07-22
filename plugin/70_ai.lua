local later, ai_mode = Config.later, Config.ai_mode

-- opencode
later(function()
  vim.pack.add({ "https://github.com/sudo-tee/opencode.nvim" })
  if ai_mode == "opencode" then
    require("opencode").setup({
      preferred_picker = "snacks",
    })
  end
end)

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
