-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("nvim_highlight_yank", { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

vim.api.nvim_create_user_command("CopyAbsolutePath", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify('Copied "' .. path .. '" to the clipboard')
end, {})

vim.api.nvim_create_user_command("CopyRelativePath", function()
  local bufferpath = vim.fn.expand("%:~:.")
  vim.fn.setreg("+", bufferpath)
  vim.notify('Copied "' .. bufferpath .. '" to the clipboard')
end, {})

-- PHP helper commands
if _G.has_project_file("composer.json") then
  local php = require("php.psr_navigation")
  vim.api.nvim_create_user_command(
    "PhpFindFQCN",
    function() php.fqcn_navigate() end,
    {}
  )
  vim.api.nvim_create_user_command(
    "CopyPHPClassFQCN",
    function() php.copy_fqcn() end,
    {}
  )
  vim.api.nvim_create_user_command(
    "CopyPHPNearMemberFQCN",
    function() php.copy_fqcn_with_near_member() end,
    {}
  )
end
