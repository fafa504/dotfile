local M = {}

local Terminal = require("toggleterm.terminal").Terminal

local function is_windows()
  local sys = vim.loop.os_uname().sysname
  return sys and sys:match("Windows")
end

local function has_exe(bin)
  return vim.fn.executable(bin) == 1
end

-- Press any key cho từng shell
local function press_any_key_zsh()
  return [[; printf "Press any key to exit..."; read -k 1 -s]]
end

local function press_any_key_bash()
  return [[; read -n 1 -s -r -p "Press any key to exit..."]]
end

local function press_any_key_windows()
  return [[; powershell -NoProfile -Command "Read-Host 'Press any key to exit...'"]]
end

-- Lệnh build & run
local function build_run_cmd()
  local file = vim.fn.expand("%")
  local file_noex = vim.fn.expand("%:r")
  local ext = vim.fn.expand("%:e")
  local ft = vim.bo.filetype

  if ext == "py" or ft == "python" then
    local py = has_exe("python3") and "python3" or "python"
    return string.format('%s "%s"', py, file)
  elseif ext == "js" or ft == "javascript" then
    return string.format('node "%s"', file)
  elseif ext == "ts" or ft == "typescript" then
    if has_exe("ts-node") then
      return string.format('ts-node "%s"', file)
    elseif has_exe("bun") then
      return string.format('bun run "%s"', file)
    else
      return string.format(
        'tsc "%s" --outDir "%s.dist" && node "%s.dist/%s.js" && rm -rf "%s.dist"',
        file,
        file_noex,
        file_noex,
        vim.fn.fnamemodify(file, ":t"):gsub("%.ts$", ""),
        file_noex
      )
    end
  elseif ext == "lua" or ft == "lua" then
    return string.format('lua "%s"', file)
  elseif ext == "sh" or ft == "sh" or ft == "bash" then
    return string.format('bash "%s"', file)
  elseif ext == "go" or ft == "go" then
    return string.format('go run "%s"', file)
  elseif ext == "rs" or ft == "rust" then
    local first = vim.fn.getline(1) or ""
    local has_shebang_rust_script = first:match("^#!%S*rust%-script")
    local cargo = vim.fn.findfile("Cargo.toml", ".;")
    if has_shebang_rust_script and has_exe("rust-script") then
      return string.format('rust-script "%s"', file)
    end
    if cargo ~= "" then
      return "cargo run"
    end
    if has_exe("rust-script") then
      return string.format('rust-script "%s"', file)
    elseif has_exe("cargo-script") then
      return string.format('cargo script "%s"', file)
    else
      local out = file_noex
      if is_windows() then
        return string.format('rustc "%s" -O -o "%s" && "%s" && del "%s.exe"', file, out, out, out)
      else
        return string.format('rustc "%s" -O -o "%s" && "%s" && rm -f "%s"', file, out, out, out)
      end
    end
  elseif ext == "c" or ft == "c" then
    local cc = has_exe("gcc") and "gcc" or (has_exe("clang") and "clang" or nil)
    if not cc then
      return nil
    end
    local out = file_noex
    if is_windows() then
      return string.format('%s "%s" -O2 -Wall -o "%s" && "%s" && del "%s.exe"', cc, file, out, out, out)
    else
      return string.format('%s "%s" -O2 -Wall -o "%s" && "%s" && rm -f "%s"', cc, file, out, out, out)
    end
  elseif ext == "cpp" or ext == "cc" or ext == "cxx" or ft == "cpp" then
    local cxx = has_exe("g++") and "g++" or (has_exe("clang++") and "clang++" or nil)
    if not cxx then
      return nil
    end
    local out = file_noex
    if is_windows() then
      return string.format('%s "%s" -O2 -Wall -std=c++17 -o "%s" && "%s" && del "%s.exe"', cxx, file, out, out, out)
    else
      return string.format('%s "%s" -O2 -Wall -std=c++17 -o "%s" && "%s" && rm -f "%s"', cxx, file, out, out, out)
    end
  elseif ext == "java" or ft == "java" then
    local dir = vim.fn.expand("%:p:h")
    local base = vim.fn.expand("%:t:r")
    if is_windows() then
      return string.format('javac "%s" && cd "%s" && java "%s" && del "%s.class"', file, dir, base, base)
    else
      return string.format('javac "%s" && cd "%s" && java "%s" && rm -f "%s.class"', file, dir, base, base)
    end
  end

  return nil
end

-- Bao lệnh trong shell (zsh ưu tiên)
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

function M.run_current_file()
  local core = build_run_cmd()
  if not core then
    vim.notify("Chưa hỗ trợ file này hoặc thiếu compiler/interpreter trong PATH.", vim.log.levels.WARN)
    return
  end

  local cmd = wrap_with_shell(core)
  local term = Terminal:new({
    cmd = cmd,
    direction = "float",
    hidden = true,
    close_on_exit = true,
  })
  term:toggle()
end

return M
