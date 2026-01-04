local ls = require("luasnip")
local s, t, i = ls.snippet, ls.text_node, ls.insert_node

return {
  -- SFC skeleton
  s("sfc", {
    t({ '<script setup lang="ts">', "" }),
    t({ "", "</script>", "", "<template>", "  " }),
    i(0, "<div>Hello</div>"),
    t({ "", "</template>", "" }),
    t({ "", "<style scoped>", "</style>" }),
  }),

  -- defineProps + emits
  s("vprops", {
    t({ '<script setup lang="ts">', "interface Props { " }),
    i(1, "title?: string"),
    t({ " }", "const props = defineProps<Props>()", "", "const emit = defineEmits<{ (e: 'submit', v: " }),
    i(2, "string"),
    t({ "): void }>()", "</script>" }),
  }),

  -- fetch onMounted
  s("vfetch", {
    t({ '<script setup lang="ts">', "import { ref, onMounted } from 'vue'", "const data = ref<" }),
    i(1, "any"),
    t({
      ">()",
      "const error = ref<Error | null>(null)",
      "",
      "onMounted(async () => {",
      "  try {",
      "    const res = await fetch(",
    }),
    i(2, "'/api'"),
    t({
      ")",
      "    if (!res.ok) throw new Error(`HTTP ${res.status}`)",
      "    data.value = await res.json()",
      "  } catch (e) {",
      "    error.value = e as Error",
      "  }",
      "})",
      "</script>",
    }),
    t({ "", "<template>", "  <pre>{{ data }}</pre>", "</template>" }),
  }),
}
