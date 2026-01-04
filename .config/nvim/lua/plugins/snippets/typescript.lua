local ls = require("luasnip")
local s, t, i, c = ls.snippet, ls.text_node, ls.insert_node, ls.choice_node

return {
  -- hàm async chuẩn + try/catch
  s("afn", {
    t("export async function "),
    i(1, "name"),
    t("("),
    i(2, "args: unknown"),
    t({ "): Promise<" }),
    i(3, "void"),
    t({ "> {", "  try {", "    " }),
    i(0, "// code"),
    t({ "", "  } catch (e) {", "    console.error(e)", "    throw e", "  }", "}" }),
  }),

  -- type / interface nhanh
  s("type", { t("export type "), i(1, "Name"), t(" = "), i(0, "{ id: string }") }),
  s("iface", { t("export interface "), i(1, "Name"), t({ " {", "  " }), i(0, "id: string"), t({ "", "}" }) }),

  -- import
  s("imp", { t("import "), i(1, "{ something }"), t(" from '"), i(2, "module"), t("'") }),

  -- console utils
  s("clg", { t("console.log("), i(0, "'value'"), t(")") }),
  s("ctm", { t("console.time("), i(1, "'label'"), t({ ")", "/* ... */", "console.timeEnd(" }), i(1), t(")") }),

  -- zod schema
  s("zod", {
    t({ "import { z } from 'zod'", "", "const " }),
    i(1, "Schema"),
    t({ " = z.object({", "  " }),
    i(0, "id: z.string()"),
    t({ "", "})", "", "type " }),
    i(2, "T"),
    t({ " = z.infer<typeof " }),
    i(1),
    t({ ">" }),
  }),
}
