local ls = require("luasnip")
local s, t, i, c = ls.snippet, ls.text_node, ls.insert_node, ls.choice_node

return {
  -- create table
  s("ctbl", {
    t("CREATE TABLE "),
    i(1, "public.table"),
    t({ " (", "  id BIGSERIAL PRIMARY KEY,", "  " }),
    i(0, "name TEXT NOT NULL"),
    t({ "", ");" }),
  }),

  -- upsert (Postgres)
  s("upsert", {
    t({ "INSERT INTO " }),
    i(1, "table"),
    t({ " (" }),
    i(2, "cols"),
    t({ ") VALUES (" }),
    i(3, "vals"),
    t({ ") ON CONFLICT (" }),
    i(4, "id"),
    t({ ") DO UPDATE SET " }),
    i(5, "col = EXCLUDED.col"),
    t(";"),
  }),

  -- index
  s("idx", {
    t({ "CREATE INDEX IF NOT EXISTS " }),
    i(1, "idx_name"),
    t({ " ON " }),
    i(2, "table"),
    t({ " (" }),
    i(3, "col"),
    t({ ");" }),
  }),

  -- transaction
  s("tx", {
    t({ "BEGIN;", "" }),
    i(0, "-- statements"),
    t({ "", "COMMIT;" }),
  }),
}
