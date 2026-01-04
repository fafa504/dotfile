return {
  {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter", -- đảm bảo LuaSnip được load trước khi load snippet
    build = (not LazyVim.is_win())
        and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp"
      or nil,
    dependencies = {
      "rafamadriz/friendly-snippets",
      {
        "saghen/blink.compat",
        optional = true,
        opts = {},
        version = not vim.g.lazyvim_blink_main and "*",
      },
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
    config = function(_, opts)
      local ls = require("luasnip")
      ls.config.setup(opts)

      require("luasnip.loaders.from_vscode").lazy_load()

      require("luasnip.loaders.from_lua").load({ paths = { "~/.config/nvim/lua/plugins/snippets" } })

      -- (tuỳ chọn) keymap expand/jump cơ bản
      vim.keymap.set({ "i", "s" }, "<C-k>", function()
        if ls.expand_or_jumpable() then
          ls.expand_or_jump()
        end
      end, { desc = "LuaSnip expand/jump" })
      vim.keymap.set({ "i", "s" }, "<C-j>", function()
        if ls.jumpable(-1) then
          ls.jump(-1)
        end
      end, { desc = "LuaSnip jump back" })
    end,
  },

  {
    "rafamadriz/friendly-snippets",
    dependencies = {
      {
        "saghen/blink.compat",
        optional = true, -- chỉ load nếu extras cần
        opts = {},
        version = not vim.g.lazyvim_blink_main and "*",
      },
    },
  },
}
