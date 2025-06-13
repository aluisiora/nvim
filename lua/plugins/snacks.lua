return {
  {
    "snacks.nvim",
    opts = function(_, opts)
      opts.scroll = { enabled = false }
      opts.notifier = { enabled = false }
      opts.picker = {
        layout = {
          cycle = false,
          preset = "ivy",
        },
      }
    end,
  },
}
