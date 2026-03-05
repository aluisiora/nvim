local mini_path = vim.fn.stdpath("data") .. "/site/pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local origin = "https://github.com/nvim-mini/mini.nvim"
  local clone_cmd = { "git", "clone", "--filter=blob:none", origin, mini_path }
  vim.fn.system(clone_cmd)
  vim.cmd("packadd mini.nvim | helptags ALL")
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end
require("mini.deps").setup()

_G.Config = {}

-- Some plugins and 'mini.nvim' modules only need setup during startup if Neovim
-- is started like `nvim -- path/to/file`, otherwise delaying setup is fine
_G.Config.now_if_args = vim.fn.argc(-1) > 0 and MiniDeps.now or MiniDeps.later

-- Some functionality is only useful for certain projects and when certain binaries
-- are available on the system
_G.has_executable = function(exec) return vim.fn.executable(exec) == 1 end
_G.has_project_file = function(filename)
  local path = vim.fn.getcwd() .. "/" .. filename
  local stat = vim.loop.fs_stat(path)
  return stat ~= nil
end
