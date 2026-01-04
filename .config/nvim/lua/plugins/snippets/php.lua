-- ~/.config/nvim/luasnippets/php.lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  -- declare(strict_types=1);
  s("strict", {
    t("declare(strict_types=1);"),
  }),

  -- __invoke method
  s("inv", {
    t("public function __invoke("),
    i(1),
    t("): "),
    i(2, "void"),
    t({ ")", "{" }),
    t("    "),
    i(3),
    t({ "", "}", "" }),
  }),

  -- public method
  s("pubf", {
    t("public function "),
    i(1),
    t("("),
    i(2),
    t("): "),
    i(3, "void"),
    t({ "", "{" }),
    t("    "),
    i(0),
    t({ "", "}", "" }),
  }),

  -- protected method
  s("prof", {
    t("protected function "),
    i(1),
    t("("),
    i(2),
    t("): "),
    i(3, "void"),
    t({ "", "{" }),
    t("    "),
    i(0),
    t({ "", "}", "" }),
  }),

  -- private method
  s("prif", {
    t("private function "),
    i(1),
    t("("),
    i(2),
    t("): "),
    i(3, "void"),
    t({ "", "{" }),
    t("    "),
    i(0),
    t({ "", "}", "" }),
  }),

  -- public static method
  s("pubsf", {
    t("public static function "),
    i(1),
    t("("),
    i(2),
    t("): "),
    i(3, "void"),
    t({ "", "{" }),
    t("    "),
    i(0),
    t({ "", "}", "" }),
  }),

  -- Pest test: it(...)
  s("it", {
    t("it('"),
    i(1),
    t({ "', function () {", "    // Arrange" }),
    t({ "", "    " }),
    i(0),
    t({ "", "", "    // Act", "", "    // Assert", "", "});" }),
  }),
}
