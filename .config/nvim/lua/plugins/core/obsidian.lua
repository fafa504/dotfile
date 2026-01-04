-- https://github.com/epwalsh/obsidian.nvim

return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
  --   "BufReadPre path/to/my-vault/**.md",
  --   "BufNewFile path/to/my-vault/**.md",
  -- },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",

    -- see below for full list of optional dependencies 👇
  },
  opts = {
    workspaces = {
      {
        name = "obsidian_main",
        path = "~/Documents/[2] Obsidian",
      },
      -- {
      --   name = "work",
      --   path = "~/vaults/work",
      -- },
    },

    disable_frontmatter = true,
    -- Optional, for templates (see below).
    templates = {
      folder = "99_Archive/01 Templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
    },

    -- Specify how to handle attachments.
    attachments = {
      img_folder = "_image", -- This is the default
    },

    -- Optional, completion of wiki links, local markdown links, and tags using nvim-cmp.
    completion = {
      -- Set to false to disable completion.
      nvim_cmp = true,
      -- Trigger completion at 2 chars.
      min_chars = 2,
    },

    vim.keymap.set("n", "<leader>im", function()
      vim.cmd("ObsidianPasteImg")
    end, { desc = "Insert Image Obsidian" }),

    vim.keymap.set("n", "<leader>tp", function()
      vim.cmd("ObsidianTemplate note-template")
      local LINE_NUM = 13
      local line = vim.fn.getline(LINE_NUM)
      local title = line:match("# (.*)")

      if title then
        title = title:gsub("_%d%d%d%d%-%d%d%-%d%d$", "")
        title = title:gsub("[_%-]", " ")
        title = title:gsub("%s+$", "")
        vim.fn.setline(LINE_NUM, "# " .. title)
      end
      vim.cmd("noh")
    end, { desc = "Insert Template" }),

    daily_notes = {
      -- Optional, if you keep daily notes in a separate directory.
      folder = "250-daily",
      -- folder = "notes/dailies",
      -- Optional, if you want to change the date format for the ID of daily notes.
      date_format = "%Y-%m-%d",
      -- Optional, if you want to change the date format of the default alias of daily notes.
      alias_format = "%B %-d, %Y",
      -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
      template = nil,
    },

    -- see below for full list of options 👇
  },
}
