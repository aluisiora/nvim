local now, later = MiniDeps.now, MiniDeps.later
local now_if_args = _G.Config.now_if_args

-- Icon provider. Usually no need to use manually. It is used by plugins like
-- 'mini.pick', 'mini.files', 'mini.statusline', and others.
now(function()
  -- Set up to not prefer extension-based icon for some extensions
  local ext3_blocklist = { scm = true, txt = true, yml = true }
  local ext4_blocklist = { json = true, yaml = true }
  require("mini.icons").setup({
    use_file_extension = function(ext, _) return not (ext3_blocklist[ext:sub(-3)] or ext4_blocklist[ext:sub(-4)]) end,
  })

  -- Mock 'nvim-tree/nvim-web-devicons' for plugins without 'mini.icons' support.
  -- Not needed for 'mini.nvim' or MiniMax, but might be useful for others.
  later(MiniIcons.mock_nvim_web_devicons)

  -- Add LSP kind icons. Useful for 'mini.completion'.
  later(MiniIcons.tweak_lsp_kind)
end)

-- Session management. A thin wrapper around `:h mksession` that consistently
-- manages session files.
now(function() require("mini.sessions").setup() end)

-- Start screen. This is what is shown when you open Neovim like `nvim`.
now(function() require("mini.starter").setup() end)

-- Statusline. Sets `:h 'statusline'` to show more info in a line below window.
now(function() require("mini.statusline").setup() end)

-- Completion and signature help. Implements async "two stage" autocompletion:
-- - Based on attached LSP servers that support completion.
-- - Fallback (based on built-in keyword completion) if there is no LSP candidates.
now_if_args(function()
  -- Customize post-processing of LSP responses for a better user experience.
  -- Don't show 'Text' suggestions (usually noisy) and show snippets last.
  local process_items_opts = { kind_priority = { Text = -1, Snippet = 99 } }
  local process_items = function(items, base)
    return MiniCompletion.default_process_items(items, base, process_items_opts)
  end
  require("mini.completion").setup({
    lsp_completion = {
      -- Without this config autocompletion is set up through `:h 'completefunc'`.
      -- Although not needed, setting up through `:h 'omnifunc'` is cleaner
      -- (sets up only when needed) and makes it possible to use `<C-u>`.
      source_func = "omnifunc",
      auto_setup = false,
      process_items = process_items,
    },
  })

  -- Set 'omnifunc' for LSP completion only when needed.
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("mini-lsp-completion", { clear = true }),
    desc = "Set 'omnifunc'",
    callback = function(event)
      vim.bo[event.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
      vim.bo[event.buf].completeopt = "menuone,noselect,noinsert,fuzzy"
    end,
  })

  -- Advertise to servers that Neovim now supports certain set of completion and
  -- signature features through 'mini.completion'.
  vim.lsp.config("*", { capabilities = MiniCompletion.get_lsp_capabilities() })
end)

-- Miscellaneous small but useful functions.
later(function() require("mini.extra").setup() end)

-- Extend and create a/i textobjects, like `:h a(`, `:h a'`, and more).
-- Contains not only `a` and `i` type of textobjects, but also their "next" and
-- "last" variants that will explicitly search for textobjects after and before
-- cursor.
later(function() require("mini.ai").setup({ search_method = "cover" }) end)

-- Align text interactively.
later(function() require("mini.align").setup() end)

-- Go forward/backward with square brackets. Implements consistent sets of mappings
-- for selected targets (like buffers, diagnostic, quickfix list entries, etc.).
later(function() require("mini.bracketed").setup() end)

-- Remove buffers. Opened files occupy space in tabline and buffer picker.
-- When not needed, they can be removed.
later(function() require("mini.bufremove").setup() end)

-- Show next key clues in a bottom right window. Requires explicit opt-in for
-- keys that act as clue trigger.
later(function()
  local miniclue = require("mini.clue")
  -- stylua: ignore
  miniclue.setup({
    clues = {
      Config.leader_group_clues,
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.square_brackets(),
      miniclue.gen_clues.windows({ submode_resize = true }),
      miniclue.gen_clues.z(),
    },
    triggers = {
      { mode = { 'n', 'x' }, keys = '<Leader>' }, -- Leader triggers
      { mode = { 'n', 'x' }, keys = '[' },        -- mini.bracketed
      { mode = { 'n', 'x' }, keys = ']' },
      { mode =   'i',        keys = '<C-x>' },    -- Built-in completion
      { mode = { 'n', 'x' }, keys = 'g' },        -- `g` key
      { mode = { 'n', 'x' }, keys = "'" },        -- Marks
      { mode = { 'n', 'x' }, keys = '`' },
      { mode = { 'n', 'x' }, keys = '"' },        -- Registers
      { mode = { 'i', 'c' }, keys = '<C-r>' },
      { mode =   'n',        keys = '<C-w>' },    -- Window commands
      { mode = { 'n', 'x' }, keys = 's' },        -- `s` key (mini.surround, etc.)
      { mode = { 'n', 'x' }, keys = 'z' },        -- `z` key
    },
  })
end)

-- Command line tweaks. Improves command line editing with:
-- - Autocompletion. Basically an automated `:h cmdline-completion`.
-- - Autocorrection of words as-you-type. Like `:W`->`:w`, `:lau`->`:lua`, etc.
-- - Autopeek command range (like line number at the start) as-you-type.
later(function() require("mini.cmdline").setup() end)

-- Comment lines. Provides functionality to work with commented lines.
-- Uses `:h 'commentstring'` option to infer comment structure.
later(function() require("mini.comment").setup() end)

-- Work with diff hunks that represent the difference between the buffer text and
-- some reference text set by a source. Default source uses text from Git index.
-- Also provides summary info used in developer section of 'mini.statusline'.
later(function() require("mini.diff").setup() end)

-- Navigation is done using column view (Miller columns) to display nested
-- directories, they are displayed in floating windows in top left corner.
later(function()
  require("mini.files").setup()
  vim.api.nvim_create_autocmd("User", {
    group = vim.api.nvim_create_augroup("mini-files-bookmarks", { clear = true }),
    pattern = "MiniFilesExplorerOpen",
    desc = "Add bookmarks",
    callback = function()
      MiniFiles.set_bookmark("c", vim.fn.stdpath("config"), { desc = "Config" })
      local minideps_plugins = vim.fn.stdpath("data") .. "/site/pack/deps/opt"
      MiniFiles.set_bookmark("p", minideps_plugins, { desc = "Plugins" })
      MiniFiles.set_bookmark("w", vim.fn.getcwd, { desc = "Working directory" })
    end,
  })
end)

-- Git integration for more straightforward Git actions based on Neovim's state.
later(function() require("mini.git").setup() end)

-- Highlight patterns in text. Like `TODO`/`NOTE` or color hex codes.
later(function()
  local hipatterns = require("mini.hipatterns")
  local hi_words = MiniExtra.gen_highlighter.words
  hipatterns.setup({
    highlighters = {
      -- Highlight a fixed set of common words. Will be highlighted in any place,
      -- not like "only in comments".
      fixme = hi_words({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
      hack = hi_words({ "HACK", "Hack", "hack" }, "MiniHipatternsHack"),
      todo = hi_words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
      note = hi_words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),

      -- Highlight hex color string (#aabbcc) with that color as a background
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
end)

-- Visualize and work with indent scope. It visualizes indent scope "at cursor"
-- with animated vertical line. Provides relevant motions and textobjects.
later(function()
  local indentscope = require("mini.indentscope")
  indentscope.setup({
    draw = {
      animation = indentscope.gen_animation.none(),
    },
    symbol = "│",
  })
end)

-- Move any selection in any direction.
later(function()
  require("mini.move").setup({
    options = { reindent_linewise = true },
  })
end)

-- Autopairs functionality. Insert pair when typing opening character and go over
-- right character if it is already to cursor's right.
later(function()
  -- Create pairs not only in Insert, but also in Command line mode
  require("mini.pairs").setup({ modes = { command = true } })
end)

-- Pick anything with single window layout and fast matching. This is one of
-- the main usability improvements as it powers a lot of "find things quickly"
-- workflows.
later(function() require("mini.pick").setup() end)

-- Manage and expand snippets (templates for a frequently used text).
-- Typical workflow is to type snippet's (configurable) prefix and expand it
-- into a snippet session.
later(function()
  -- Define language patterns to work better with 'friendly-snippets'
  local latex_patterns = { "latex/**/*.json", "**/latex.json" }
  local lang_patterns = {
    tex = latex_patterns,
    plaintex = latex_patterns,
    -- Recognize special injected language of markdown tree-sitter parser
    markdown_inline = { "markdown.json" },
  }

  local snippets = require("mini.snippets")
  local config_path = vim.fn.stdpath("config")
  snippets.setup({
    snippets = {
      -- Always load 'snippets/global.json' from config directory
      snippets.gen_loader.from_file(config_path .. "/snippets/global.json"),
      -- Load from 'snippets/' directory of plugins, like 'friendly-snippets'
      snippets.gen_loader.from_lang({ lang_patterns = lang_patterns }),
    },
  })
end)

-- Split and join arguments (regions inside brackets between allowed separators).
-- It uses Lua patterns to find arguments, which means it works in comments and
-- strings but can be not as accurate as tree-sitter based solutions.
later(function()
  local splitjoin = require("mini.splitjoin")
  local add_trailing_comma = splitjoin.gen_hook.add_trailing_separator({})
  local del_trailing_comma = splitjoin.gen_hook.del_trailing_separator({})
  splitjoin.setup({
    split = { hooks_post = { add_trailing_comma } },
    join = { hooks_post = { del_trailing_comma } },
  })
end)

-- Surround actions: add/delete/replace/find/highlight. Working with surroundings
-- is surprisingly common: surround word with quotes, replace `)` with `]`, etc.
later(function() require("mini.surround").setup() end)

-- Highlight and remove trailspace. Temporarily stops highlighting in Insert mode
-- to reduce noise when typing.
later(function() require("mini.trailspace").setup() end)
