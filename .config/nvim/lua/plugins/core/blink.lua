return {
  {
    "saghen/blink.compat",
    version = "2.*",
    lazy = true,
    opts = {},
  },

  {
    "saghen/blink.cmp",
    enabled = true,
    dependencies = {
      "rafamadriz/friendly-snippets",
      { "L3MON4D3/LuaSnip", version = "v2.*" },
      {
        "stevearc/vim-vscode-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
          -- dùng đường dẫn tuyệt đối thay vì "./"
          require("luasnip.loaders.from_vscode").lazy_load({
            paths = vim.fn.stdpath("config") .. "/my_snippets",
          })
        end,
      },
    },
    opts = function(_, opts)
      -- tắt ở một số ft
      opts.enabled = function()
        local ft = vim.bo[0].filetype
        if ft == "TelescopePrompt" or ft == "minifiles" or ft == "snacks_picker_input" then
          return false
        end
        return true
      end

      -- >>> CHỈNH Ở ĐÂY: dùng 'snippets' thay 'luasnip', bỏ compat.luasnip <<<
      opts.sources = vim.tbl_deep_extend("force", opts.sources or {}, {
        default = { "lsp", "path", "snippets", "buffer", "lazydev" },
        providers = {
          lsp = {
            name = "lsp",
            enabled = true,
            module = "blink.cmp.sources.lsp",
            kind = "LSP",
            min_keyword_length = 0,
            score_offset = 90,
          },
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
          path = {
            name = "Path",
            module = "blink.cmp.sources.path",
            score_offset = 25,
            fallbacks = { "snippets", "buffer" },
            opts = {
              trailing_slash = false,
              label_trailing_slash = true,
              get_cwd = function(context)
                return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
              end,
              show_hidden_files_by_default = true,
            },
          },
          buffer = {
            name = "Buffer",
            enabled = true,
            max_items = 3,
            module = "blink.cmp.sources.buffer",
            min_keyword_length = 2,
            score_offset = 15,
          },
          snippets = { -- nguồn snippets MỚI của blink
            name = "snippets",
            enabled = true,
            max_items = 15,
            min_keyword_length = 2,
            module = "blink.cmp.sources.snippets",
            score_offset = 85,
          },
        },
      })

      -- cmdline
      opts.cmdline = { enabled = true }

      -- UI
      opts.completion = {
        menu = { border = "single" },
        documentation = {
          auto_show = true,
          window = { border = "single" },
        },
      }

      -- dùng LuaSnip làm preset cho nguồn snippets
      opts.snippets = { preset = "luasnip" }

      -- keymaps
      opts.keymap = {
        preset = "default",
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<S-k>"] = { "scroll_documentation_up", "fallback" },
        ["<S-j>"] = { "scroll_documentation_down", "fallback" },
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e"] = { "hide", "fallback" },
      }

      return opts
    end,
  },
}
