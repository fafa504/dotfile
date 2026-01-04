local ls = require("luasnip")
local s, t, i, f, c = ls.snippet, ls.text_node, ls.insert_node, ls.function_node, ls.choice_node

-- helper: tên file -> tên component
local function filename_to_comp(args, snip)
  local name = vim.fn.expand("%:t:r")
  if name == "" then
    return "Component"
  end
  -- PascalCase đơn giản
  name = name:gsub("[-_](%l)", function(c)
    return c:upper()
  end)
  name = name:gsub("^%l", string.upper)
  return name
end

return {
  -- React FC + props
  s("rfc", {
    t("import React from 'react'"),
    t({ ";", "" }),
    t("interface "),
    i(1, "Props"),
    t({ " {", "  " }),
    i(2, "title?: string"),
    t({ "", "}", "" }),
    t("const "),
    f(filename_to_comp, {}),
    t(": React.FC<"),
    i(3, "Props"),
    t({ "> = (" }),
    t({ "props" }, { "" }),
    t({ ") => {", "  return (" }),
    t({ "    <div>" }),
    i(0, "hello"),
    t({ "</div>", "  )", "}", "" }),
    t("export default "),
    f(filename_to_comp, {}),
  }),

  -- component tối giản (no props)
  s("cmp", {
    t("function "),
    f(filename_to_comp, {}),
    t({ "() {", "  return (" }),
    t({ "    <div>" }),
    i(0, "…"),
    t({ "</div>", "  )", "}", "" }),
    t("export default "),
    f(filename_to_comp, {}),
  }),

  -- useState
  s("us", {
    t("const ["),
    i(1, "state"),
    t(", set"),
    f(function(args)
      return (args[1][1] or "State"):gsub("^%l", string.upper)
    end, { 1 }),
    t("] = React.useState<"),
    i(2, "type"),
    t(">("),
    i(3, "initial"),
    t(")"),
  }),

  -- useEffect
  s("ue", {
    t({ "React.useEffect(() => {", "  " }),
    i(1, "// side effects"),
    t({ "", "  return () => { " }),
    i(2, "// cleanup"),
    t({ " }", "" }),
    t("}, ["),
    i(3, "deps"),
    t("])"),
  }),

  -- useCallback
  s("ucb", {
    t({ "const " }),
    i(1, "handler"),
    t({ " = React.useCallback((" }),
    i(2, "args"),
    t({ ") => {", "  " }),
    i(3, "// ..."),
    t({ "", "}, [" }),
    i(4, "deps"),
    t({ "])" }),
  }),

  -- useMemo
  s("um", {
    t({ "const " }),
    i(1, "value"),
    t({ " = React.useMemo(() => {", "  " }),
    i(2, "compute"),
    t({ "", "}, [" }),
    i(3, "deps"),
    t({ "])" }),
  }),

  -- sự kiện input
  s("onchg", {
    t({ "const " }),
    i(1, "onChange"),
    t({ ": React.ChangeEventHandler<HTMLInputElement> = (e) => {", "  " }),
    i(0, "setValue(e.target.value)"),
    t({ "", "}" }),
  }),

  -- fetch + useEffect
  s("fetch", {
    t({ "const [data, setData] = React.useState<" }),
    i(1, "any"),
    t({
      ">();",
      "const [loading, setLoading] = React.useState(true)",
      "const [error, setError] = React.useState<Error | null>(null)",
      "",
      "React.useEffect(() => {",
      "  let ignore = false",
      "  async function run() {",
      "    try {",
      "      setLoading(true)",
      "      const res = await fetch(",
    }),
    i(2, "'/api'"),
    t({
      ")",
      "      if (!res.ok) throw new Error(`HTTP ${res.status}`)",
      "      const json = await res.json()",
      "      if (!ignore) setData(json)",
      "    } catch (e) {",
      "      if (!ignore) setError(e as Error)",
      "    } finally {",
      "      if (!ignore) setLoading(false)",
      "    }",
      "  }",
      "  run()",
      "  return () => { ignore = true }",
      "}, [",
    }),
    i(3, "deps"),
    t({ "])" }),
  }),

  -- Next.js page cơ bản (App Router)
  s("npage", {
    t({ "export default function " }),
    f(filename_to_comp, {}),
    t({ "() {", "  return (" }),
    t({ '    <main className="min-h-dvh p-6">' }),
    i(0, "Hello"),
    t({ "</main>", "  )", "}" }),
  }),
}
