local ls = require("luasnip")
local s, t, i, c = ls.snippet, ls.text_node, ls.insert_node, ls.choice_node

return {
  -- front matter YAML
  s("fm", {
    t({ "---", "title: " }),
    i(1, "Tiêu đề"),
    t({ "", "date: " }),
    i(2, "2025-09-20"),
    t({ "", "tags: [" }),
    i(3, "note, dev"),
    t({ "]", "draft: " }),
    i(4, "false"),
    t({ "", "---", "" }),
    i(0),
  }),

  -- heading nhanh (#, ##, ###)
  s("h1", { t("# "), i(0, "Heading 1") }),
  s("h2", { t("## "), i(0, "Heading 2") }),
  s("h3", { t("### "), i(0, "Heading 3") }),

  -- code fence có ngôn ngữ
  s("code", {
    t("```"),
    i(1, "lang"),
    t({ "", "" }),
    i(0, "// code"),
    t({ "", "```" }),
  }),

  -- blockquote note/hint
  s("note", {
    t({ "> **Note**: " }),
    i(0, "ghi chú"),
  }),
  s("warn", {
    t({ "> **Warning**: " }),
    i(0, "cẩn thận"),
  }),

  -- danh sách tác vụ (checklist)
  s("todo", {
    t({ "- [ ] " }),
    i(1, "việc 1"),
    t({ "", "- [ ] " }),
    i(2, "việc 2"),
    t({ "", "- [ ] " }),
    i(0, "việc 3"),
  }),

  -- bảng cơ bản
  s("table", {
    t({ "| " }),
    i(1, "Cột 1"),
    t({ " | " }),
    i(2, "Cột 2"),
    t({ " |" }),
    t({ "", "|---|---|", "| " }),
    i(3, "Giá trị 1"),
    t({ " | " }),
    i(4, "Giá trị 2"),
    t({ " |" }),
  }),

  -- link & image
  s("link", { t("["), i(1, "văn bản"), t("]("), i(2, "https://example.com"), t(")") }),
  s("img", { t("!["), i(1, "alt"), t("]("), i(2, "path/to/img.png"), t(")") }),

  -- footnote
  s("foot", {
    t({ "Tham khảo[^" }),
    i(1, "1"),
    t({ "]", "", "[^" }),
    i(1),
    t({ "]: " }),
    i(0, "nội dung chú thích"),
  }),

  -- callout kiểu GitHub (blockquote + tiêu đề)
  s("callout", {
    t({ "> [!" }),
    i(1, "NOTE"),
    t({ "] " }),
    i(2, "Tiêu đề"),
    t({ "", "> " }),
    i(0, "Nội dung…"),
  }),
}
