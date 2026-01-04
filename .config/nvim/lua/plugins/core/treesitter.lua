return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    version = false, -- dùng branch main
    build = function()
      local TS = require("nvim-treesitter")
      if not TS.get_installed then
        LazyVim.error("Please restart Neovim and run `:TSUpdate` to use the `nvim-treesitter` **main** branch.")
        return
      end
      LazyVim.treesitter.ensure_treesitter_cli(function()
        TS.update(nil, { summary = true })
      end)
    end,
    lazy = vim.fn.argc(-1) == 0,
    event = { "LazyFile", "VeryLazy" },
    cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
    opts_extend = { "ensure_installed" },
    ---@class lazyvim.TSConfig: TSConfig
    opts = {
      indent = { enable = true },
      highlight = { enable = true },
      folds = { enable = true },
      ensure_installed = {
        "blade",
        "jsp",
        "php_only",
        "html",
        "css",
        "dockerfile",
        "bash",
        "c",
        "git_config",
        "gitcommit",
        "git_rebase",
        "gitignore",
        "gitattributes",
        "diff",
        "javascript",
        "java",
        "json5",
        "jsdoc",
        "json",
        "jsonc",
        "rust",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "query",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
        "cpp",
        "cmake",
      },
    },
    ---@param opts lazyvim.TSConfig
    config = function(_, opts)
      local TS = require("nvim-treesitter")
      setmetatable(require("nvim-treesitter.install"), {
        __newindex = function(_, k)
          if k == "compilers" then
            vim.schedule(function()
              LazyVim.error({
                "Setting custom compilers for `nvim-treesitter` is no longer supported.",
                "",
                "For more info, see:",
                "- [compilers](https://docs.rs/cc/latest/cc/#compile-time-requirements)",
              })
            end)
          end
        end,
      })

      if not TS.get_installed then
        return LazyVim.error("Please use `:Lazy` and update `nvim-treesitter`")
      elseif type(opts.ensure_installed) ~= "table" then
        return LazyVim.error("`nvim-treesitter` opts.ensure_installed must be a table")
      end

      TS.setup(opts)
      LazyVim.treesitter.get_installed(true)

      local install = vim.tbl_filter(function(lang)
        return not LazyVim.treesitter.have(lang)
      end, opts.ensure_installed or {})

      if #install > 0 then
        LazyVim.treesitter.ensure_treesitter_cli(function()
          TS.install(install, { summary = true }):await(function()
            LazyVim.treesitter.get_installed(true)
          end)
        end)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("lazyvim_treesitter", { clear = true }),
        callback = function(ev)
          if not LazyVim.treesitter.have(ev.match) then
            return
          end
          if vim.tbl_get(opts, "highlight", "enable") ~= false then
            pcall(vim.treesitter.start)
          end
          if vim.tbl_get(opts, "indent", "enable") ~= false and LazyVim.treesitter.have(ev.match, "indents") then
            LazyVim.set_default("indentexpr", "v:lua.LazyVim.treesitter.indentexpr()")
          end
          if vim.tbl_get(opts, "folds", "enable") ~= false and LazyVim.treesitter.have(ev.match, "folds") then
            if LazyVim.set_default("foldmethod", "expr") then
              LazyVim.set_default("foldexpr", "v:lua.LazyVim.treesitter.foldexpr()")
            end
          end
        end,
      })
    end,
  },
}
