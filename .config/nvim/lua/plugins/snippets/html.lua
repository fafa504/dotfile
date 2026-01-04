-- ~/.config/nvim/luasnippets/html.lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("html5", {
    t({ "<!doctype html>", '<html lang="' }),
    i(1, "en"),
    t({ '">', "<head>" }),
    t({
      '  <meta charset="utf-8" />',
      '  <meta name="viewport" content="width=device-width, initial-scale=1" />',
      "  <title>",
    }),
    i(2, "Title"),
    t({ "</title>" }),
    t({ '  <meta name="description" content="' }),
    i(3),
    t({ '" />' }),
    t({ '  <link rel="stylesheet" href="' }),
    i(4, "styles.css"),
    t({ '">', "</head>", "<body>" }),
    t("  "),
    i(0),
    t({ "", '  <script src="' }),
    i(5, "main.js"),
    t({ '" defer></script>', "</body>", "</html>" }),
  }),

  s("linkcss", {
    t('<link rel="stylesheet" href="'),
    i(1, "styles.css"),
    t('" />'),
  }),

  s("scriptm", {
    t({ '<script type="module">', "  " }),
    i(0),
    t({ "", "</script>" }),
  }),

  s("scriptd", {
    t('<script src="'),
    i(1, "main.js"),
    t('" defer></script>'),
  }),

  s("viewport", {
    t('<meta name="viewport" content="width=device-width, initial-scale=1" />'),
  }),

  s("img", {
    t('<img src="'),
    i(1, "img.png"),
    t('" alt="'),
    i(2, "description"),
    t('" width="'),
    i(3),
    t('" height="'),
    i(4),
    t('" />'),
  }),

  s("a", {
    t('<a href="'),
    i(1, "#"),
    t('">'),
    i(0, "link"),
    t("</a>"),
  }),

  s("divc", {
    t('<div class="'),
    i(1, "container"),
    t({ '">', "  " }),
    i(0),
    t({ "", "</div>" }),
  }),

  s("tcdn", {
    t('<script src="https://cdn.tailwindcss.com"></script>'),
  }),
}
