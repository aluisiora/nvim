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

-- Lsp helper commands
vim.api.nvim_create_user_command("LspRestart", function()
  -- Get all active LSP clients attached to the current buffer
  local clients = vim.lsp.get_clients({ bufnr = 0 })

  if #clients == 0 then
    vim.notify("No LSP clients attached to this buffer.", vim.log.levels.WARN)
    return
  end

  -- Collect ALL buffers that share these specific clients
  local attached_buffers = {}
  for _, client in ipairs(clients) do
    for bufnr, _ in pairs(client.attached_buffers) do
      attached_buffers[bufnr] = true
    end
    -- Stop the client globally
    vim.lsp.stop_client(client.id)
  end

  -- Wait 500ms for graceful shutdown
  vim.defer_fn(function()
    local count = 0
    -- Re-trigger the FileType event for every orphaned buffer
    for bufnr, _ in pairs(attached_buffers) do
      if vim.api.nvim_buf_is_valid(bufnr) then
        count = count + 1
        -- Execute in the context of the specific buffer
        vim.api.nvim_buf_call(bufnr, function()
          local ft = vim.bo[bufnr].filetype
          if ft and ft ~= "" then vim.cmd("doautocmd FileType " .. ft) end
        end)
      end
    end
    vim.notify(
      "LSP restarted and reattached to " .. count .. " buffer(s).",
      vim.log.levels.INFO
    )
  end, 500)
end, { desc = "Restart native LSP clients and reattach all related buffers" })
