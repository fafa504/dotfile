local M = {}
local Terminal = require("toggleterm.terminal").Terminal

-- Detect Windows
local function is_windows()
  return vim.loop.os_uname().sysname:match("Windows")
end

-- Check if an executable exists
local function has_exe(bin)
  return vim.fn.executable(bin) == 1
end

-- "Press any key to exit..." helpers
local function press_any_key_zsh()
  return [[;  read -k 1 -s]]
end

local function press_any_key_bash()
  return [[; read -n 1 -s -r ]]
end

local function press_any_key_windows()
  return [[; powershell -NoProfile -Command "Read-Host 'Press any key to exit...'"]]
end

-- Wrap a command with the right shell + pause message
local function wrap_with_shell(cmd_core)
  if is_windows() then
    return cmd_core .. " " .. press_any_key_windows()
  end
  if has_exe("zsh") then
    return string.format("zsh -i -l -c '%s%s'", cmd_core, press_any_key_zsh())
  else
    return string.format("bash -i -l -c '%s%s'", cmd_core, press_any_key_bash())
  end
end

-- Floating terminal with `tree` command
local tree = Terminal:new({
  cmd = wrap_with_shell("eza --tree --icons --git --level=3"),
  hidden = true,
  direction = "float",
  float_opts = {
    border = "curved",
    width = function()
      return math.floor(vim.o.columns * 0.6)
    end,
    height = function()
      return math.floor(vim.o.lines * 0.6)
    end,
  },
  on_open = function(term)
    local opts = { noremap = true, silent = true, buffer = term.bufnr }

    -- leave terminal insert mode
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)

    -- map 'q' to close the float
    vim.keymap.set("n", "q", "<cmd>close<CR>", opts)
  end,
})

function M.tree_toggle()
  tree:toggle()
end

return M
