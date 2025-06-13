return {
  {
    "catppuccin/nvim",
    opts = function(_, opts)
      opts.flavour = "mocha"
      opts.transparent_background = true
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options.theme = "catppuccin"
      opts.options.section_separators = {
        left = "",
        right = "",
      }
      opts.options.component_separators = {
        left = "",
        right = "",
      }
      opts.sections.lualine_y = { "encoding", "fileformat", "progress" }
      opts.sections.lualine_z = { "location" }

      return opts
    end,
  },
}
