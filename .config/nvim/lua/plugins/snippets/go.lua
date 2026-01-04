local ls = require("luasnip")
local s, t, i = ls.snippet, ls.text_node, ls.insert_node

return {
  -- main
  s("gmain", {
    t({ "package main", "", 'import "fmt"', "", "func main() {", "    " }),
    i(0, 'fmt.Println("hello")'),
    t({ "", "}" }),
  }),

  -- error-returning func
  s("gfn", {
    t({ "func " }),
    i(1, "Name"),
    t({ "(" }),
    i(2, "args"),
    t({ ") (" }),
    i(3, "res type"),
    t({ ", error) {", "    " }),
    i(0, "return /* res */, nil"),
    t({ "", "}" }),
  }),

  -- http handler
  s("ghdl", {
    t({ "func " }),
    i(1, "handler"),
    t({ "(w http.ResponseWriter, r *http.Request) {", "    " }),
    i(0, 'w.Write([]byte("ok"))'),
    t({ "", "}" }),
  }),

  -- test
  s("gtest", {
    t({ "package " }),
    i(1, "pkg"),
    t({ "", 'import "testing"', "", "func Test" }),
    i(2, "Name"),
    t({ "(t *testing.T) {", "    " }),
    i(0),
    t({ "", "}" }),
  }),
}
