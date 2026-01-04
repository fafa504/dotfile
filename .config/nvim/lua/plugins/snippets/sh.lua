local ls = require("luasnip")
local s, t, i, c = ls.snippet, ls.text_node, ls.insert_node, ls.choice_node

return {
  -- script template an toàn
  s("sh!", {
    t({
      "#!/usr/bin/env bash",
      "set -euo pipefail",
      "IFS=$'\\n\\t'",
      "",
      "main() {",
      "  ",
    }),
    i(0, "# TODO"),
    t({ "", "}", "", 'main "$@"' }),
  }),

  -- trap lỗi
  s("traperr", {
    t({ "trap 'echo \"[ERR] ${BASH_SOURCE[0]}:${LINENO}\" >&2; exit 1' ERR" }),
  }),

  -- biến env với mặc định
  s("env?", { t({ ": ${" }), i(1, "VAR"), t({ ":=" }), i(2, "default"), t({ "}" }) }),

  -- for file
  s("forf", {
    t({ "for f in " }),
    i(1, "*.txt"),
    t({ " ; do", "  " }),
    i(0, 'echo "$f"'),
    t({ "", "done" }),
  }),

  -- function
  s("fn", {
    t({ "function " }),
    i(1, "name"),
    t({ "() {", "  " }),
    i(0),
    t({ "", "}" }),
  }),

  -- curl tải file (follow redirects, fail)
  s("curlf", {
    t({ "curl -fsSL " }),
    i(1, "https://example.com"),
    t({ " -o " }),
    i(2, "out.file"),
  }),

  -- read input với prompt
  s("readp", {
    t({ 'read -rp "' }),
    i(1, "Prompt: "),
    t({ '" ' }),
    i(2, "var"),
  }),

  -- case
  s("case", {
    t({ "case " }),
    i(1, "$1"),
    t({ " in", "  " }),
    i(2, "start"),
    t({ ")" }),
    t({ " " }),
    i(3, "# ..."),
    t({ " ;;", "  " }),
    i(4, "stop"),
    t({ ")" }),
    t({ " " }),
    i(5, "# ..."),
    t({ " ;;", '  * ) echo "unknown" ;;', "esac" }),
  }),
}
