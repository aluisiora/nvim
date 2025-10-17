local nixdir = vim.env.HOME .. '/.config/nixos'
local hostname = vim.uv.os_gethostname()

return {
  cmd = { "nixd" },
  filetypes = { "nix" },
  root_markers = { "flake.nix", ".git" },
  settings = {
    nixd = {
      nixpkgs = {
        expr = "import <nixpkgs> { }",
      },
      options = {
        nixos = {
          expr = '(builtins.getFlake "' .. nixdir .. '").nixosConfigurations.' .. hostname .. '.options',
        },
        -- home_manager = {
        --   expr = '(builtins.getFlake "' .. nixdir .. '").homeConfigurations.' .. hostname .. '.options',
        -- },
      },
    },
  },
}

