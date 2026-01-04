return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- PHP
        "php-cs-fixer",
        "pint",
        "phpactor",
        "blade-formatter",

        -- Markdown
        "markdownlint-cli2",
        "markdown-toc",

        -- Docker
        "hadolint",

        -- Debugger
        "codelldb",

        -- C / C++
        "clangd", -- LSP server cho C/C++
        "clang-format", -- Formatter cho C/C++

        "tree-sitter-cli",

        -- python
        "ruff",

        -- lua
        "lua-language-server",
        "stylua",

        -- format
        "eslint-lsp",
        "prettier",

        -- Rust
        -- "rust-analyzer",

        -- Web development
        "typescript-language-server",
        "tailwindcss-language-server",
        "css-lsp",
        "html-lsp",
        "json-lsp",
        "emmet-ls",
      },
    },
  },
}
