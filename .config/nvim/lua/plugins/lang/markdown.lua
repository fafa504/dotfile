-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/render-markdown.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/render-markdown.lua

-- https://github.com/MeanderingProgrammer/markdown.nvim
--
-- When I hover over markdown headings, this plugins goes away, so I need to
-- edit the default highlights
-- I tried adding this as an autocommand, in the options.lua
-- file, also in the markdownl.lua file, but the highlights kept being overriden
-- so the inly way is the only way I was able to make it work was loading it
-- after the config.lazy in the init.lua file lamw25wmal

-- Define color variables
-- These are the colors for the eldritch colorscheme
local color1_bg = "#f265b5"
local color2_bg = "#37f499"
local color3_bg = "#04d1f9"
local color4_bg = "#a48cf2"
local color5_bg = "#f1fc79"
local color6_bg = "#f7c67f"
local color_fg = "#323449"
-- local color_sign = "#ebfafa"

return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    enabled = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter", -- Syntax highlighting support
      "nvim-lua/plenary.nvim", -- Common Lua utilities
    },
    opts = {
      code = {
        enabled = true, -- Enable rendering for code blocks & inline code
        inline = true, -- Enable inline code rendering
        sign = true, -- Add icons in the sign column
        conceal_delimiters = true, -- Hide backticks or fences
        language = true, -- Show language above code blocks
        language_icon = true, -- Show icon for language
        language_name = true, -- Show language name
        language_info = true, -- Show info string after language
        position = "left", -- Language label on the left
        width = "full", -- Stretch background across window width
        border = "hide", -- Hide top/bottom border unless label exists
        disable_background = { "diff" }, -- Don't double-highlight `diff` blocks
        highlight = "RenderMarkdownCode", -- Code highlight group
        highlight_info = "RenderMarkdownCodeInfo", -- Info text
        highlight_border = "RenderMarkdownCodeBorder", -- Border color
        highlight_inline = "RenderMarkdownCodeInline", -- Inline code highlight
        style = "normal", -- Use all rendering features
      },
      heading = {
        sign = false,
        icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },

        -- Heading colors (when not hovered over), extends through the entire line
        vim.cmd(string.format([[highlight Headline1Bg guifg=%s guibg=%s]], color_fg, color1_bg)),
        vim.cmd(string.format([[highlight Headline2Bg guifg=%s guibg=%s]], color_fg, color2_bg)),
        vim.cmd(string.format([[highlight Headline3Bg guifg=%s guibg=%s]], color_fg, color3_bg)),
        vim.cmd(string.format([[highlight Headline4Bg guifg=%s guibg=%s]], color_fg, color4_bg)),
        vim.cmd(string.format([[highlight Headline5Bg guifg=%s guibg=%s]], color_fg, color5_bg)),
        vim.cmd(string.format([[highlight Headline6Bg guifg=%s guibg=%s]], color_fg, color6_bg)),

        -- Highlight for the heading and sign icons (symbol on the left)
        -- I have the sign disabled for now, so this makes no effect
        vim.cmd(string.format([[highlight Headline1Fg cterm=bold gui=bold guifg=%s]], color1_bg)),
        vim.cmd(string.format([[highlight Headline2Fg cterm=bold gui=bold guifg=%s]], color2_bg)),
        vim.cmd(string.format([[highlight Headline3Fg cterm=bold gui=bold guifg=%s]], color3_bg)),
        vim.cmd(string.format([[highlight Headline4Fg cterm=bold gui=bold guifg=%s]], color4_bg)),
        vim.cmd(string.format([[highlight Headline5Fg cterm=bold gui=bold guifg=%s]], color5_bg)),
        vim.cmd(string.format([[highlight Headline6Fg cterm=bold gui=bold guifg=%s]], color6_bg)),

        backgrounds = {
          "Headline1Bg",
          "Headline2Bg",
          "Headline3Bg",
          "Headline4Bg",
          "Headline5Bg",
          "Headline6Bg",
        },
        foregrounds = {
          "Headline1Fg",
          "Headline2Fg",
          "Headline3Fg",
          "Headline4Fg",
          "Headline5Fg",
          "Headline6Fg",
        },
      },
    },
    {
      "iamcco/markdown-preview.nvim",
      cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
      build = function()
        require("lazy").load({ plugins = { "markdown-preview.nvim" } })
        vim.fn["mkdp#util#install"]()
      end,
      keys = {
        {
          "<leader>cp",
          ft = "markdown",
          "<cmd>MarkdownPreviewToggle<cr>",
          desc = "Markdown Preview",
        },
      },
      config = function()
        vim.cmd([[do FileType]])
      end,
    },
    {
      "stevearc/conform.nvim",
      optional = true,
      opts = {
        formatters = {
          ["markdown-toc"] = {
            condition = function(_, ctx)
              for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
                if line:find("<!%-%- toc %-%->") then
                  return true
                end
              end
            end,
          },
          ["markdownlint-cli2"] = {
            condition = function(_, ctx)
              local diag = vim.tbl_filter(function(d)
                return d.source == "markdownlint"
              end, vim.diagnostic.get(ctx.buf))
              return #diag > 0
            end,
          },
        },
        formatters_by_ft = {
          ["markdown"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
          ["markdown.mdx"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        -- markdown = { "markdownlint-cli2" },
      },
    },
  },
}
