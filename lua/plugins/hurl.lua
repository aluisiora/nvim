return {
  {
    "jellydn/hurl.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- Optional, for markdown rendering with render-markdown.nvim
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown" },
        },
        ft = { "markdown" },
      },
    },
    ft = "hurl",
    opts = {
      -- Show debugging info
      debug = false,
      -- Show notification on run
      show_notification = false,
      -- Show response in popup or split
      mode = "split",
      -- Default formatter
      formatters = {
        json = { "jq" }, -- Make sure you have install jq in your system, e.g: brew install jq
        html = {
          "prettier", -- Make sure you have install prettier in your system, e.g: npm install -g prettier
          "--parser",
          "html",
        },
        xml = {
          "tidy", -- Make sure you have installed tidy in your system, e.g: brew install tidy-html5
          "-xml",
          "-i",
          "-q",
        },
      },
      -- Default mappings for the response popup or split views
      mappings = {
        close = "q", -- Close the response popup or split view
        next_panel = "<C-n>", -- Move to the next response popup window
        prev_panel = "<C-p>", -- Move to the previous response popup window
      },
    },
    config = function(_, opts)
      require("hurl").setup(opts)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "hurl",
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          -- Run API request
          vim.keymap.set("n", "<leader>A", "<cmd>HurlRunner<CR>", { buffer = buffer, desc = "Run All API requests" })
          vim.keymap.set("n", "<leader>a", "<cmd>HurlRunnerAt<CR>", { buffer = buffer, desc = "Run API request" })
          vim.keymap.set(
            "n",
            "<leader>te",
            "<cmd>HurlRunnerToEntry<CR>",
            { buffer = buffer, desc = "Run API request to entry" }
          )
          vim.keymap.set(
            "n",
            "<leader>tE",
            "<cmd>HurlRunnerToEnd<CR>",
            { buffer = buffer, desc = "Run API request from current entry to end" }
          )
          vim.keymap.set("n", "<leader>tm", "<cmd>HurlToggleMode<CR>", { buffer = buffer, desc = "Hurl Toggle Mode" })
          vim.keymap.set(
            "n",
            "<leader>tv",
            "<cmd>HurlVerbose<CR>",
            { buffer = buffer, desc = "Run API in verbose mode" }
          )
          vim.keymap.set(
            "n",
            "<leader>tV",
            "<cmd>HurlVeryVerbose<CR>",
            { buffer = buffer, desc = "Run API in very verbose mode" }
          )
          -- Run Hurl request in visual mode
          vim.keymap.set("v", "<leader>h", ":HurlRunner<CR>", { buffer = buffer, desc = "Hurl Runner" })
        end,
      })
    end,
  },
}
