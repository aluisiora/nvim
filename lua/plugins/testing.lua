return {
  { "thenbe/neotest-playwright" },
  { "olimorris/neotest-phpunit" },
  { "nvim-neotest/neotest-jest" },
  { "fredrikaverpil/neotest-golang" },
  {
    "nvim-neotest/neotest",
    event = "LspAttach",
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}

      -- golang
      table.insert(
        opts.adapters,
        require("neotest-golang")({
          dap_go_enabled = true,
          go_test_args = {
            "-v",
            "-race",
            "-count=1",
            "-timeout=60s",
            "-coverprofile=" .. vim.fn.getcwd() .. "/coverage.out",
          },
        })
      )

      -- phpunit
      table.insert(opts.adapters, require("neotest-phpunit"))

      -- jest
      table.insert(
        opts.adapters,
        require("neotest-jest")({
          jestCommand = "npm run test -- --detectOpenHandles",
          jest_test_discovery = false,
        })
      )

      -- playwright
      table.insert(
        opts.adapters,
        require("neotest-playwright").adapter({
          options = {
            persist_project_selection = true,
            enable_dynamic_test_discovery = true,
          },
        })
      )

      return opts
    end,
  },
}
