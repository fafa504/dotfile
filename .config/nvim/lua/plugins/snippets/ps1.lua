-- ~/.config/nvim/luasnippets/ps1.lua
local ls = require("luasnip")
local s, t, i = ls.snippet, ls.text_node, ls.insert_node

return {
  -- script header
  s("pshdr", {
    t({ "<#", " .SYNOPSIS", "   " }),
    i(1, "Script description"),
    t({ "", " .NOTES", "   Author: " }),
    i(2, "you"),
    t({ "", "#>", "" }),
  }),

  -- param block
  s("param", {
    t({ "param(", "    [Parameter(Mandatory=$true)]", "    [" }),
    i(1, "string"),
    t("]$"),
    i(2, "Name"),
    t({ "", ")" }),
  }),

  -- function
  s("fn", {
    t("function "),
    i(1, "Get-Thing"),
    t({ " {", "    param(", "        " }),
    i(2, "[string]$Input"),
    t({ "", "    )", "    " }),
    i(0, "# code"),
    t({ "", "}" }),
  }),

  -- try/catch
  s("tryc", {
    t({ "try {", "    " }),
    i(1, "# code"),
    t({ "", "} catch {", "    Write-Error $_", "}" }),
  }),

  -- foreach
  s("foreach", {
    t("foreach ($"),
    i(1, "item"),
    t(" in "),
    i(2, "collection"),
    t({ ") {", "    " }),
    i(0),
    t({ "", "}" }),
  }),

  -- pipeline with Where-Object
  s("where", {
    t("| Where-Object { $_."),
    i(1, "Property"),
    t(" -eq "),
    i(2, "Value"),
    t(" }"),
  }),

  -- Write-Output / Write-Error / Write-Debug quickies
  s("wo", { t("Write-Output "), i(0, "'text'") }),
  s("we", { t("Write-Error "), i(0, "'error'") }),
  s("wd", { t("Write-Debug "), i(0, "'debug'") }),

  -- shebang for pwsh
  s("shebang", { t("#!/usr/bin/env pwsh") }),
}
