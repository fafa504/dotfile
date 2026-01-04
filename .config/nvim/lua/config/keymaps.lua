-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = LazyVim.safe_keymap_set

map("n", "Y", "<cmd>%y+<cr>", { desc = "Copy all text", remap = true })
map("n", "<C-q>", ":q<CR>", { desc = "quit", silent = true })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Move Lines
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>bd", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })
map("n", "<leader>bo", function()
  Snacks.bufdelete.other()
end, { desc = "Delete Other Buffers" })
map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })

-- Clear search and stop snippet on escape
map({ "i", "n", "s" }, "<esc>", function()
  vim.cmd("noh")
  LazyVim.cmp.actions.snippet_stop()
  return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
map(
  "n",
  "<leader>ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / Clear hlsearch / Diff Update" }
)

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- save file
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

--keywordprg
map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- commenting
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- lazy
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- new file
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

map("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Location List" })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix List" })

map("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })

-- formatting
map({ "n", "v" }, "<leader>cf", function()
  LazyVim.format({ force = true })
end, { desc = "Format" })

-- diagnostic
local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

-- stylua: ignore start

-- toggle options
LazyVim.format.snacks_toggle():map("<leader>uf")
LazyVim.format.snacks_toggle(true):map("<leader>uF")
Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.line_number():map("<leader>ul")
Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" }):map("<leader>uc")
Snacks.toggle.option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" }):map("<leader>uA")
Snacks.toggle.treesitter():map("<leader>uT")
Snacks.toggle.option("background", { off = "light", on = "dark" , name = "Dark Background" }):map("<leader>ub")
Snacks.toggle.dim():map("<leader>uD")
Snacks.toggle.animate():map("<leader>ua")
Snacks.toggle.indent():map("<leader>ug")
Snacks.toggle.scroll():map("<leader>uS")
Snacks.toggle.profiler():map("<leader>dpp")
Snacks.toggle.profiler_highlights():map("<leader>dph")

if vim.lsp.inlay_hint then
  Snacks.toggle.inlay_hints():map("<leader>uh")
end

-- lazygit
if vim.fn.executable("lazygit") == 1 then
  map("n", "<leader>gg", function() Snacks.lazygit( { cwd = LazyVim.root.git() }) end, { desc = "Lazygit (Root Dir)" })
  map("n", "<leader>gG", function() Snacks.lazygit() end, { desc = "Lazygit (cwd)" })
  map("n", "<leader>gf", function() Snacks.lazygit.log_file() end, { desc = "Lazygit Current File History" })
  map("n", "<leader>gl", function() Snacks.lazygit.log({ cwd = LazyVim.root.git() }) end, { desc = "Lazygit Log" })
  map("n", "<leader>gL", function() Snacks.lazygit.log() end, { desc = "Lazygit Log (cwd)" })
end

map("n", "<leader>gb", function() Snacks.git.blame_line() end, { desc = "Git Blame Line" })
map({ "n", "x" }, "<leader>gB", function() Snacks.gitbrowse() end, { desc = "Git Browse (open)" })
map({"n", "x" }, "<leader>gY", function()
  Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false })
end, { desc = "Git Browse (copy)" })

-- quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- highlights under cursor
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
map("n", "<leader>uI", "<cmd>InspectTree<cr>", { desc = "Inspect Tree" })

-- LazyVim Changelog
map("n", "<leader>L", function() LazyVim.news.changelog() end, { desc = "LazyVim Changelog" })

-- floating terminal
local Terminal = require("toggleterm.terminal").Terminal
local lazy_root = require("lazyvim.util").root 
map("n", "<leader>ft", function()
  local term = Terminal:new({
    dir = lazy_root(), -- project root
    direction = "float",
    float_opts = { border = "rounded" },
    hidden = true,
  })
  term:toggle()
end, { desc = "Floating Terminal (Root Dir)" })

-- Terminal Mappin
map("t", "<C-/`", "<cmd>close<cr>", { desc = "Hide Terminal" })

-- windows
map("n", "<leader>w", "<c-w>", { desc = "Windows", remap = true })
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })
Snacks.toggle.zoom():map("<leader>wm"):map("<leader>uZ")
Snacks.toggle.zen():map("<leader>uz")

-- tabs
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })


-- native snippets. only needed on < 0.11, as 0.11 creates these by default
if vim.fn.has("nvim-0.11") == 0 then
  map("s", "<Tab>", function()
    return vim.snippet.active({ direction = 1 }) and "<cmd>lua vim.snippet.jump(1)<cr>" or "<Tab>"
  end, { expr = true, desc = "Jump Next" })
  map({ "i", "s" }, "<S-Tab>", function()
    return vim.snippet.active({ direction = -1 }) and "<cmd>lua vim.snippet.jump(-1)<cr>" or "<S-Tab>"
  end, { expr = true, desc = "Jump Previous" })
end

-- Define the function to perform the Google search
-- Define the GoogleSearch function
function GoogleSearch()
  local searchterm = vim.fn.getreg('"')
  vim.cmd('silent !firefox "https://www.google.com/search?q=' .. searchterm .. '" &')
end

map('n', '<leader>ss', ':lua GoogleSearch()<CR>', { noremap = true, silent = true })
-- (Obtain yazi.nvim and its dependencies using your preferred method first)

map('i', '<C-h>', '<Left>', { noremap = true })
map('i', '<C-j>', '<Down>', { noremap = true })
map('i', '<C-l>', '<Right>', { noremap = true })
map("i", "<C-o>", "<Esc>o", { noremap = true })

vim.keymap.set('n', '<leader>op', function()
  local clip_content = vim.fn.system('wl-paste')
  vim.cmd('%delete _')
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(clip_content, '\n'))
  vim.notify("File content replaced with system clipboard", vim.log.levels.INFO)
end, { desc = 'Overwrite file with system clipboard content (wl-paste)' })
map("n", "<leader>t", ":terminal<CR>", { noremap = true })

-- Lấy các API cần thiết từ vim
local api = vim.api
local cmd = vim.cmd
local opt_local = vim.opt_local
local bo = vim.bo

-- Tạo một nhóm autocommand mới (sẽ xóa các autocommand cũ cùng tên)
local terminal = api.nvim_create_augroup("TerminalLocalOptions", { clear = true })

-- Autocommand khi mở terminal mới
api.nvim_create_autocmd("TermOpen", {
  group = terminal,
  pattern = "*", -- áp dụng cho tất cả terminal
  callback = function(event)
    -- Tắt các tuỳ chọn hiển thị không cần thiết trong terminal
    opt_local.number = false
    opt_local.relativenumber = false
    opt_local.cursorline = false
    opt_local.signcolumn = "no"
    opt_local.statuscolumn = ""

    -- Mã thoát khỏi terminal mode
    local code_term_esc = api.nvim_replace_termcodes("<C-\\><C-n>", true, true, true)

    -- Thiết lập các phím điều hướng <C-h/j/k/l> trong chế độ terminal
    for _, key in ipairs({ "h", "j", "k", "l" }) do
      vim.keymap.set("t", "<C-" .. key .. ">", function()
        local code_dir = api.nvim_replace_termcodes("<C-" .. key .. ">", true, true, true)
        api.nvim_feedkeys(code_term_esc .. code_dir, "t", true)
      end, { noremap = true, buffer = event.buf })
    end

    -- Nếu filetype chưa được đặt, đặt là 'terminal'
    if bo.filetype == "" then
      vim.api.nvim_set_option_value("filetype", "terminal", { buf = event.buf })
    end

    -- Tự động vào insert mode nếu tùy chọn được bật
    if vim.g.catgoose_terminal_enable_startinsert == 1 then
      cmd("startinsert")
    end
  end,
})

-- Autocommand khi chuyển vào cửa sổ terminal (ví dụ chuyển cửa sổ bằng <C-w>h)
api.nvim_create_autocmd("WinEnter", {
  group = terminal,
  pattern = "*",
  callback = function()
    if vim.bo.filetype == "terminal" and vim.g.catgoose_terminal_enable_startinsert == 1 then
      cmd("startinsert")
    end
  end,
})

local function convert_md()
  local formats = { "pdf", "docx", "html", "odt", "epub" }

  local file = vim.fn.expand("%:p")        -- full path to current file
  local base_name = vim.fn.expand("%:t:r") -- filename without extension
  local output_folder = vim.fn.expand("%:p:h") .. "/" -- current folder
  local image_folder = "/home/mintori/Documents/Obsidian/_image"

  if file == "" then
    print("No file to convert!")
    return
  end

  vim.ui.select(formats, { prompt = "Output format" }, function(choice)
    if not choice then
      print("No format selected")
      return
    end
    local output_path = output_folder .. base_name .. "." .. choice
    local cmd_line = { "pandoc", file, "-o", output_path }
    if choice == "pdf" then
      table.insert(cmd_line, "--pdf-engine=xelatex")
    end
    if vim.fn.isdirectory(image_folder) == 1 then
      table.insert(cmd_line, "--resource-path=" .. image_folder)
    end
    local result = vim.fn.system(cmd_line)
    if vim.v.shell_error == 0 then
      print("Converted to " .. output_path)
    else
      print("Pandoc failed:\n" .. result)
    end
  end)
end

vim.keymap.set("n", "<leader>mc", convert_md, { desc = "Convert MD and choose output folder" })

local function reload_nvim_conf()
  for name,_ in pairs(package.loaded) do
    if name:match('^core') or name:match('^lsp') or name:match('^plugins') then
      package.loaded[name] = nil
    end
  end

  dofile(vim.env.MYVIMRC)
  vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO)
end

vim.keymap.set("n", "<leader>rl", reload_nvim_conf, { desc = "Reload all config neovim" })

vim.api.nvim_create_user_command("LivePreview", function()
  -- Get Neovim's current working directory
  local cwd = vim.fn.getcwd()

  -- Run live-server with --open so it launches the browser automatically
  vim.fn.jobstart({ "live-server", "--open", cwd }, {
    detach = true, -- keep running independently
  })

  print("Live-server started in " .. cwd .. " (browser opened)")
end, {})

local function open_link()
  vim.cmd('normal! "zy')
  local link = vim.fn.getreg("z"):gsub("^%s+", ""):gsub("%s+$", "")

  if link ~= "" then
    local cmd = string.format("xdg-open '%s' &", link)
    os.execute(cmd)
  else
    vim.notify("No link selected", vim.log.levels.WARN)
  end
end

vim.keymap.set("v", "<leader>ol", open_link, { desc = "Open link in default browser" })
vim.keymap.set("n", "<leader>r", function()
  require("util.runner").run_current_file()
end, { desc = "Run current file (float term)" })
vim.keymap.set("n", "<leader>dt", function()
  require("util.tree").tree_toggle()
end, { noremap = true, silent = true, desc = "Float tree" })

vim.api.nvim_create_user_command('GeminiClean', function()
  local cleaner = require('util.gemini_cleaner')
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local text = table.concat(lines, "\n")
  local clean_text = cleaner.clean(text)
  local new_lines = vim.split(clean_text, "\n")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
end, {})
