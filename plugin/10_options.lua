vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.termguicolors = true
vim.o.title = true
vim.o.number = true
vim.o.wrap = false
vim.o.cursorline = true
vim.o.scrolloff = 12
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.splitkeep = "cursor"
vim.o.winborder = "single"
vim.o.hlsearch = true
vim.o.autoindent = true
vim.o.smartindent = false
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.swapfile = false
vim.o.backup = false
vim.o.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.o.undofile = true
vim.o.encoding = "utf-8"
vim.o.fileencoding = "utf-8"
vim.o.signcolumn = "yes"
vim.o.showmode = false
vim.o.background = "dark"
vim.o.backspace = "start,eol,indent"

-- Line folding
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.api.nvim_create_autocmd({ "BufReadPost", "FileReadPost" }, {
  group = vim.api.nvim_create_augroup("open_folds", { clear = true }),
  pattern = "*",
  command = "normal zR",
})
