return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    -- 1. Định nghĩa các custom formatters hoặc ghi đè tham số
    opts.formatters = vim.tbl_extend("force", opts.formatters or {}, {
      gemini_cleaner = {
        format = function(bufnr)
          local text = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
          local ok, cleaner = pcall(require, "util.gemini_cleaner")
          if not ok then
            vim.notify("Failed to load util.gemini_cleaner: " .. tostring(cleaner), vim.log.levels.ERROR)
            return
          end
          local cleaned_text = cleaner.clean(text)
          return vim.split(cleaned_text, "\n")
        end,
      },
      prettierd = { timeout_ms = 5000 },
      shfmt = {
        prepend_args = { "-i", "2", "-ci" },
      },
    })

    -- 2. Cấu hình formatters theo FileType (Sử dụng gán trực tiếp hoặc tbl_deep_extend)
    opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
      -- Web: Ưu tiên prettierd (nhanh), fallback về prettier
      javascript = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      vue = { "prettierd", "prettier", stop_after_first = true },
      css = { "prettierd", "prettier", stop_after_first = true },
      scss = { "prettierd", "prettier", stop_after_first = true },
      html = { "prettierd", "prettier", stop_after_first = true },
      json = { "prettierd", "prettier", stop_after_first = true },
      jsonc = { "prettierd", "prettier", stop_after_first = true },
      yaml = { "prettierd", "prettier", stop_after_first = true },
      graphql = { "prettierd", "prettier", stop_after_first = true },

      -- Markdown: Kết hợp cleaner của bạn + format code blocks bên trong
      markdown = { "gemini_cleaner", "prettierd", "prettier", "injected", stop_after_first = false },

      -- Python: Ruff là nhanh nhất hiện tại
      python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },

      -- Lua
      lua = { "stylua" },

      -- Shell
      sh = { "shfmt" },
      bash = { "shfmt" },
      zsh = { "shfmt" },

      -- PHP
      php = { "pint", "php_cs_fixer", stop_after_first = true },

      -- Go & Rust
      go = { "goimports", "gofmt" },
      rust = { "rustfmt" },

      -- Infrastructure & Config
      toml = { "taplo" },
      nix = { "alejandra" },
      terraform = { "terraform_fmt" },
      sql = { "sql_formatter" },
      dockerfile = { "hadolint" },

      -- Java & C-style
      java = { "google-java-format" },
      c = { "clang-format" },
      cpp = { "clang-format" },
      cs = { "csharpier" },

      ["_"] = { "trim_whitespace" },
    })
  end,
}
