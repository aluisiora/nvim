-- Mapping helpers ============================================================
local nmap = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { desc = desc }) end
local nmap_leader = function(suffix, rhs, desc) vim.keymap.set("n", "<Leader>" .. suffix, rhs, { desc = desc }) end
local xmap_leader = function(suffix, rhs, desc) vim.keymap.set("x", "<Leader>" .. suffix, rhs, { desc = desc }) end
local lsp_maps = {}
local nmap_lsp = function(lhs, rhs, desc) table.insert(lsp_maps, { lhs = lhs, rhs = rhs, desc = desc }) end

-- General mappings ===========================================================
nmap("x", '"_x') -- Prevent coping character to registry
nmap("<Esc>", "<Cmd>nohlsearch<CR>") -- Clear highlighted search
nmap("<C-h>", "<C-w><C-h>", "Focus left")
nmap("<C-l>", "<C-w><C-l>", "Focus right")
nmap("<C-j>", "<C-w><C-j>", "Focus down")
nmap("<C-k>", "<C-w><C-k>", "Focus up")
nmap("]r", "<Cmd>lua Snacks.words.jump(1)<CR>", "next word reference")
nmap("[r", "<Cmd>lua Snacks.words.jump(-1)<CR>", "previous word reference")

-- Language mappings ===============================================================
nmap_lsp("grd", "<Cmd>lua vim.lsp.buf.definition()<CR>", "Source definitions")
nmap_lsp("gW", "<Cmd>lua vim.lsp.buf.workspace_symbol()<CR>", "Workpace symbols")
nmap("grN", "<Cmd>lua Snacks.rename.rename_file()<CR>", "Rename file")
nmap("grf", '<Cmd>lua require("conform").format()<CR>', "Format file")

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("custom-lsp-attach", { clear = true }),
  callback = function(event)
    for _, m in ipairs(lsp_maps) do
      vim.keymap.set("n", m.lhs, m.rhs, { desc = m.desc, buffer = event.buf })
    end
  end,
})

-- Leader mappings ============================================================
_G.Config.leader_group_clues = {
  { mode = "n", keys = "<Leader>b", desc = "+Buffer" },
  { mode = "n", keys = "<Leader>d", desc = "+Debug" },
  { mode = "n", keys = "<Leader>e", desc = "+Explore" },
  { mode = "n", keys = "<Leader>f", desc = "+Find" },
  { mode = "n", keys = "<Leader>g", desc = "+Git" },
  { mode = "x", keys = "<Leader>g", desc = "+Git" },
  { mode = "n", keys = "<Leader>s", desc = "+Session" },
  { mode = "n", keys = "<Leader>t", desc = "+Test" },
}

-- special leader direct keymaps
nmap_leader("/", '<Cmd>lua Snacks.picker.grep()<CR>', 'Grep search')
nmap_leader(":", '<Cmd>lua Snacks.picker.command_history()<CR>', 'Command history')
nmap_leader(",", '<Cmd>lua Snacks.picker.buffers()<CR>', 'Open buffers')
nmap_leader(".", '<Cmd>lua Snacks.picker.recent()<CR>', 'Recent files')
nmap_leader("<space>", '<Cmd>FFFSnacks<CR>', "Fuzzy find")

-- b is for 'Buffer'
nmap_leader("ba", "<Cmd>b#<CR>", "Alternate")
nmap_leader("bd", "<Cmd>lua MiniBufremove.delete()<CR>", "Delete")
nmap_leader("bD", "<Cmd>lua MiniBufremove.delete(0, true)<CR>", "Delete!")
nmap_leader("bw", "<Cmd>lua MiniBufremove.wipeout()<CR>", "Wipeout")
nmap_leader("bW", "<Cmd>lua MiniBufremove.wipeout(0, true)<CR>", "Wipeout!")

-- d is for 'Debug'
local breakpoint_condition = '<Cmd>lua require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))'

nmap_leader("ds", '<Cmd>lua require("dap").continue()<CR>', "Start/Continue")
nmap_leader("di", '<Cmd>lua require("dap").step_into()<CR>', "Step Into")
nmap_leader("dv", '<Cmd>lua require("dap").step_over()<CR>', "Step Over")
nmap_leader("do", '<Cmd>lua require("dap").step_out()<CR>', "Step Out")
nmap_leader("da", '<Cmd>lua require("dap").toggle_breakpoint()<CR>', "Add breakpoint")
nmap_leader("dc", breakpoint_condition, "Breakpoint condition")

-- e is for 'Explore'
nmap_leader("ed", "<Cmd>lua Snacks.explorer.open()<CR>", "Directory")
nmap_leader("ef", "<Cmd>lua Snacks.explorer.reveal()<CR>", "File directory")

-- f is for 'Find'
nmap_leader("ff", "<Cmd>lua Snacks.picker.files()<CR>", "Files")
nmap_leader("fG", '<Cmd>lua Snacks.picker.grep_word()<CR>', "Grep current word")
nmap_leader("fm", "<Cmd>lua Snacks.picker.git_diff()<CR>", "Modified hunks (all)")
nmap_leader("fd", '<Cmd>lua Snacks.picker.diagnostics()<CR>', "Diagnostic workspace")
nmap_leader("fD", '<Cmd>lua Snacks.picker.diagnostics_buffer()<CR>', "Diagnostic buffer")
nmap_leader("fc", "<Cmd>lua Snacks.picker.git_log()<CR>", "Commits (all)")
nmap_leader("fC", '<Cmd>lua Snacks.picker.git_log_file()<CR>', "Commits (buf)")
nmap_leader("fB", '<Cmd>lua Snacks.picker.git_log_line()<CR>', "Commits (line)")

-- g is for 'Git'
local git_log_cmd = [[Git log --pretty=format:\%h\ \%as\ │\ \%s --topo-order]]
local git_log_buf_cmd = git_log_cmd .. " --follow -- %"

nmap_leader("gb", "<Cmd>lua Snacks.git.blame_line()<CR>", "Blame at cursor")
nmap_leader("gx", "<Cmd>lua Snacks.gitbrowse.open()<CR>", "Browse remote")
nmap_leader("ga", "<Cmd>Git diff --cached<CR>", "Added diff")
nmap_leader("gA", "<Cmd>Git diff --cached -- %<CR>", "Added diff buffer")
nmap_leader("gc", "<Cmd>Git commit<CR>", "Commit")
nmap_leader("gC", "<Cmd>Git commit --amend<CR>", "Commit amend")
nmap_leader("gd", "<Cmd>Git diff<CR>", "Diff")
nmap_leader("gD", "<Cmd>Git diff -- %<CR>", "Diff buffer")
nmap_leader("gl", "<Cmd>" .. git_log_cmd .. "<CR>", "Log")
nmap_leader("gL", "<Cmd>" .. git_log_buf_cmd .. "<CR>", "Log buffer")
nmap_leader("go", "<Cmd>lua MiniDiff.toggle_overlay()<CR>", "Toggle overlay")
nmap_leader("gs", "<Cmd>lua MiniGit.show_at_cursor()<CR>", "Show at cursor")

xmap_leader("gs", "<Cmd>lua MiniGit.show_at_cursor()<CR>", "Show at selection")

-- s is for 'Session'
local session_new = 'MiniSessions.write(vim.fn.input("Session name: "))'

nmap_leader("sd", '<Cmd>lua MiniSessions.select("delete")<CR>', "Delete")
nmap_leader("sn", "<Cmd>lua " .. session_new .. "<CR>", "New")
nmap_leader("sr", '<Cmd>lua MiniSessions.select("read")<CR>', "Read")
nmap_leader("sw", "<Cmd>lua MiniSessions.write()<CR>", "Write current")

-- t is for 'Test'
local test_output = '<Cmd>lua require("neotest").output.open({enter=true,auto_close=true})<CR>'
local test_debug_nearest = '<Cmd>lua require("neotest").run.run({suite=false,strategy="dap"})<CR>'

nmap_leader("ta", '<Cmd>lua require("neotest").run.attach()<CR>', "Attach")
nmap_leader("tf", '<Cmd>lua require("neotest").run.run(vim.fn.expand("%"))<CR>', "Run file")
nmap_leader("tA", '<Cmd>lua require("neotest").run.run(vim.uv.cwd())<CR>', "All files")
nmap_leader("tS", '<Cmd>lua require("neotest").run.run({suite=true}) end<CR>', "Suite")
nmap_leader("tn", '<Cmd>lua require("neotest").run.run()<CR>', "Nearest")
nmap_leader("tl", '<Cmd>lua require("neotest").run.run_last()<CR>', "Last test")
nmap_leader("ts", '<Cmd>lua require("neotest").summary.toggle()<CR>', "Summary")
nmap_leader("to", test_output, "Show output")
nmap_leader("tO", '<Cmd>lua require("neotest").output_panel.toggle()<CR>', "Show output panel")
nmap_leader("tt", '<Cmd>lua require("neotest").run.stop()<CR>', "Terminate")
nmap_leader("td", test_debug_nearest, "Debug nearest")
