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
  { mode = "n", keys = "<Leader>o", desc = "+Other" },
  { mode = "n", keys = "<Leader>s", desc = "+Session" },
  { mode = "n", keys = "<Leader>t", desc = "+Test" },
}

-- special fff map
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
local explore_at_file = "<Cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>"
nmap_leader("ef", explore_at_file, "File directory")
nmap_leader("ed", "<Cmd>lua MiniFiles.open()<CR>", "Directory")
nmap_leader("en", "<Cmd>lua MiniNotify.show_history()<CR>", "Notifications")

-- f is for 'Find'
local pick_added_hunks_buf = '<Cmd>Pick git_hunks path="%" scope="staged"<CR>'
local pick_workspace_symbols_live = '<Cmd>Pick lsp scope="workspace_symbol_live"<CR>'

nmap_leader("f/", '<Cmd>Pick history scope="/"<CR>', '"/" history')
nmap_leader("f:", '<Cmd>Pick history scope=":"<CR>', '":" history')
nmap_leader("fa", '<Cmd>Pick git_hunks scope="staged"<CR>', "Added hunks (all)")
nmap_leader("fA", pick_added_hunks_buf, "Added hunks (buf)")
nmap_leader("fb", "<Cmd>Pick buffers<CR>", "Buffers")
nmap_leader("fc", "<Cmd>Pick git_commits<CR>", "Commits (all)")
nmap_leader("fC", '<Cmd>Pick git_commits path="%"<CR>', "Commits (buf)")
nmap_leader("fd", '<Cmd>Pick diagnostic scope="all"<CR>', "Diagnostic workspace")
nmap_leader("fD", '<Cmd>Pick diagnostic scope="current"<CR>', "Diagnostic buffer")
nmap_leader("ff", "<Cmd>Pick files<CR>", "Files")
nmap_leader("fg", "<Cmd>Pick grep_live<CR>", "Grep live")
nmap_leader("fG", '<Cmd>Pick grep pattern="<cword>"<CR>', "Grep current word")
nmap_leader("fh", "<Cmd>Pick help<CR>", "Help tags")
nmap_leader("fH", "<Cmd>Pick hl_groups<CR>", "Highlight groups")
nmap_leader("fl", '<Cmd>Pick buf_lines scope="all"<CR>', "Lines (all)")
nmap_leader("fL", '<Cmd>Pick buf_lines scope="current"<CR>', "Lines (buf)")
nmap_leader("fm", "<Cmd>Pick git_hunks<CR>", "Modified hunks (all)")
nmap_leader("fM", '<Cmd>Pick git_hunks path="%"<CR>', "Modified hunks (buf)")
nmap_leader("fr", "<Cmd>Pick resume<CR>", "Resume")
nmap_leader("fR", '<Cmd>Pick lsp scope="references"<CR>', "References (LSP)")
nmap_leader("fs", pick_workspace_symbols_live, "Symbols workspace (live)")
nmap_leader("fS", '<Cmd>Pick lsp scope="document_symbol"<CR>', "Symbols document")
nmap_leader("fv", '<Cmd>Pick visit_paths cwd=""<CR>', "Visit paths (all)")
nmap_leader("fV", "<Cmd>Pick visit_paths<CR>", "Visit paths (cwd)")

-- g is for 'Git'
local git_log_cmd = [[Git log --pretty=format:\%h\ \%as\ │\ \%s --topo-order]]
local git_log_buf_cmd = git_log_cmd .. " --follow -- %"

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

nmap_leader("n", "<leader>ta", '<Cmd>lua require("neotest").run.attach()<CR>', "Attach")
nmap_leader("n", "<leader>tf", '<Cmd>lua require("neotest").run.run(vim.fn.expand("%"))<CR>', "Run file")
nmap_leader("n", "<leader>tA", '<Cmd>lua require("neotest").run.run(vim.uv.cwd())<CR>', "All files")
nmap_leader("n", "<leader>tS", '<Cmd>lua require("neotest").run.run({suite=true}) end<CR>', "Suite")
nmap_leader("n", "<leader>tn", '<Cmd>lua require("neotest").run.run()<CR>', "Nearest")
nmap_leader("n", "<leader>tl", '<Cmd>lua require("neotest").run.run_last()<CR>', "Last test")
nmap_leader("n", "<leader>ts", '<Cmd>lua require("neotest").summary.toggle()<CR>', "Summary")
nmap_leader("n", "<leader>to", test_output, "Show output")
nmap_leader("n", "<leader>tO", '<Cmd>lua require("neotest").output_panel.toggle()<CR>', "Show output panel")
nmap_leader("n", "<leader>tt", '<Cmd>lua require("neotest").run.stop()<CR>', "Terminate")
nmap_leader("n", "<leader>td", test_debug_nearest, "Debug nearest")
