# Neovim Configuration Overview

This is a personal Neovim configuration built with a focus on performance, modularity, and a rich feature set for multiple programming languages. It follows the [MiniMax](https://nvim-mini.org/MiniMax/) design pattern.

## Core Technologies
- **Plugin Manager:** `mini.deps` (built-in Neovim plugin management via `mini.nvim`).
- **Language Support:** Strong support for **PHP**, **Go**, **Lua**, **TypeScript/JavaScript**, **Dart/Flutter**, **Nix**, and **SQL**.
- **UI & Aesthetics:** Uses the `vague-theme`, `mini.statusline`, and `mini.icons`.
- **Search & Exploration:** Powered by `snacks.nvim` (picker, explorer, and words).

## Project Structure
- `init.lua`: Entry point, sets up `mini.deps` and global configuration helpers.
- `plugin/`: Core configuration files, loaded automatically.
    - `10_options.lua`: General Neovim options and diagnostic settings.
    - `20_keymaps.lua`: Global and leader-based keybindings.
    - `30_mini.lua`: Configuration for `mini.nvim` modules.
    - `40_plugins.lua`: External plugins like `snacks.nvim`, `treesitter`, and `undotree`.
    - `50_coding.lua`: LSP, formatting, linting, snippets, debugging, and testing setup.
    - `60_autocmds.lua`: Custom autocommands and utility commands.
- `after/lsp/`: Individual LSP server configurations (e.g., `lua_ls.lua`, `intelephense.lua`).
- `after/ftplugin/`: Filetype-specific settings.
- `lua/`: Custom Lua modules (e.g., `php/psr_navigation.lua`).
- `snippets/`: Custom snippet definitions in JSON and Lua.

## Key Features & Workflows

### 1. Development Tools
- **LSP:** Managed via `mason.nvim` and configured in `after/lsp/`. `fidget.nvim` provides progress notifications.
- **Formatting:** Handled by `conform.nvim`. Key command: `:Format` or `<Leader>grf`.
- **Linting:** Handled by `nvim-lint`. Key command: `:Lint`. Runs on `BufWritePost`.
- **Completion:** `mini.completion` provides asynchronous completion and signature help.
- **Snippets:** `mini.snippets` with `friendly-snippets`.

### 2. Navigation & Finding
- **Leader Key:** `<Space>`
- **Smart Find:** `<Leader><Space>` (via `snacks.picker.smart`)
- **File Explorer:** `<Leader>ed` or `<Leader>ef` to focus.
- **Grep Search:** `<Leader>/`
- **LSP Symbols:** `gO` (Document symbols), `gW` (Workspace symbols).

### 3. Testing & Debugging
- **Testing:** `neotest` with adapters for PHPUnit, Codeception, Golang, Jest, and Playwright. Key prefix: `<Leader>t`.
- **Debugging:** `nvim-dap` with `dap-ui`. Supports PHP (Xdebug) and Go (Delve). Key prefix: `<Leader>d`.

### 4. Git Integration
- **Hunk/Diff:** `mini.diff`.
- **Git Actions:** `mini.git` and `snacks.git`. Key prefix: `<Leader>g`.
- **Blame:** `<Leader>gb`.

### 5. Language Specifics
- **PHP:** Custom commands for FQCN navigation and copying. Uses `intelephense`, `pint`, `phpstan`.
- **Go:** Integrated with `gopls`, `neotest-golang`, and `dap-go`.
- **SQL:** Integrated with `vim-dadbod` for database management.

## Key Commands
| Command | Description |
|---------|-------------|
| `:Format` | Formats the current buffer |
| `:Lint` | Runs linters on the current buffer |
| `:CopyAbsolutePath` | Copies the current file's absolute path to clipboard |
| `:CopyRelativePath` | Copies the current file's relative path to clipboard |
| `:PhpFindFQCN` | Navigates to PHP class FQCN (Project specific) |

## Development Conventions
- **Startup Optimization:** Uses `now()`, `later()`, and `now_if_args()` to delay loading non-critical features.
- **Global Config:** `_G.Config` holds shared state; `_G.has_executable` and `_G.has_project_file` are used for conditional feature activation.
- **Styling:** Adheres to `.stylua.toml` for Lua formatting.
