return {
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      opts.cmdline = { enabled = false }
      opts.messages = { enabled = false }
      opts.popupmenu = { enabled = false }
      opts.notify = { enabled = false }
    end,
  },
}
