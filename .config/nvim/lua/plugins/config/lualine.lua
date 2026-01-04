return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      {
        function()
          local ok, laravel_version = pcall(function()
            return Laravel.app("status"):get("laravel")
          end)
          if ok then
            return laravel_version
          end
        end,
        icon = { " ", color = { fg = "#F55247" } },
        cond = function()
          local ok, has_laravel_versions = pcall(function()
            return Laravel.app("status"):has("laravel")
          end)
          return ok and has_laravel_versions
        end,
      },
      {
        function()
          local ok, php_version = pcall(function()
            return Laravel.app("status"):get("php")
          end)
          if ok then
            return php_version
          end
          return nil
        end,
        icon = { " ", color = { fg = "#AEB2D5" } },
        cond = function()
          local ok, has_php_version = pcall(function()
            return Laravel.app("status"):has("php")
          end)
          return ok and has_php_version
        end,
      },
      {
        function()
          local ok, hostname = pcall(function()
            return Laravel.extensions.composer_dev.hostname()
          end)
          if ok then
            return hostname
          end
          return nil
        end,
        icon = { " ", color = { fg = "#8FBC8F" } },
        cond = function()
          local ok, is_running = pcall(function()
            return Laravel.extensions.composer_dev.isRunning()
          end)
          return ok and is_running
        end,
      },
      {
        function()
          local ok, unseen_records = pcall(function()
            return #(Laravel.extensions.dump_server.unseenRecords())
          end)

          if ok then
            return unseen_records
          end
          return 0
        end,
        icon = { "󰱧 ", color = { fg = "#FFCC66" } },
        cond = function()
          local ok, is_running = pcall(function()
            return Laravel.extensions.dump_server.isRunning()
          end)

          return ok and is_running
        end,
      },
    },
  },
}
