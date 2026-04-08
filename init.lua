_G.Config = {}

vim.pack.add({ "https://github.com/nvim-mini/mini.nvim" })

local misc = require("mini.misc")
Config.now = function(f) misc.safely("now", f) end
Config.later = function(f) misc.safely("later", f) end
Config.now_if_args = vim.fn.argc(-1) > 0 and Config.now or Config.later

Config.on_packchanged = function(plugin_name, kinds, callback, desc)
  local f = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if not (name == plugin_name and vim.tbl_contains(kinds, kind)) then
      return
    end
    if not ev.data.active then vim.cmd.packadd(plugin_name) end
    callback(ev.data)
  end
  vim.api.nvim_create_autocmd("PackChanged", {
    pattern = "*",
    group = vim.api.nvim_create_augroup("custom-pack-changed", {}),
    desc = desc,
    callback = f,
  })
end

-- Some functionality is only useful for certain projects and when certain binaries
-- are available on the system
Config.has_executable = function(exec) return vim.fn.executable(exec) == 1 end
Config.has_project_file = function(filename)
  local path = vim.fn.getcwd() .. "/" .. filename
  local stat = vim.loop.fs_stat(path)
  return stat ~= nil
end
