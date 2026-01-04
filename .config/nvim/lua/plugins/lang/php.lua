-- lua/plugins/laravel.lua
-- Opinionated Laravel setup for Lazy.nvim: Treesitter, Blade, LSP (phpactor),
-- formatters (Pint/PHPCS Fixer/Blade), linting, and laravel.nvim keymaps.

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        phpactor = {},
      },
    },
  },

  -- 6) Linting (nvim-lint): basic php -l + phpcs (optional ruleset.xml)
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      linters_by_ft = {
        php = { "php" }, -- "php" = php -l; add a phpcs.xml if you have one
      },
    },
    config = function(_, opts)
      local lint = require("lint")
      lint.linters_by_ft = opts.linters_by_ft
      -- auto lint on save
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
