-- `# %%` code cells (jupytext's py:percent format, also VS Code's and
-- Spyder's): finding them, moving between them, selecting them, and
-- sending them to an IPython pane in tmux through vim-slime.
local M = {}

--- A line that starts a cell: `# %%`, `#%%`, `# %% [markdown]`, ...
local DELIMITER = "^%s*#%s*%%%%"

function M.is_delimiter(line)
    return line:match(DELIMITER) ~= nil
end

--- The cell holding line {lnum} (1-based) of {buf}, as `start, finish`:
--- the delimiter line (or 1, before the first delimiter) through the line
--- before the next delimiter (or the last line).
function M.range(buf, lnum)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local start, finish = 1, #lines
    for i = lnum, 1, -1 do
        if M.is_delimiter(lines[i]) then
            start = i
            break
        end
    end
    for i = lnum + 1, #lines do
        if M.is_delimiter(lines[i]) then
            finish = i - 1
            break
        end
    end
    return start, finish
end

--- The code of the cell holding {lnum}, as `start, finish` or nil for an
--- empty cell: without its delimiter line and trailing blank lines.
function M.body(buf, lnum)
    local start, finish = M.range(buf, lnum)
    local lines = vim.api.nvim_buf_get_lines(buf, start - 1, finish, false)
    if M.is_delimiter(lines[1] or "") then
        start = start + 1
    end
    while finish >= start and vim.api.nvim_buf_get_lines(buf, finish - 1, finish, false)[1]:match("^%s*$") do
        finish = finish - 1
    end
    if finish < start then
        return nil
    end
    return start, finish
end

--- The delimiter line after (+1) or before (-1) {lnum}, or nil.
function M.adjacent(buf, lnum, direction)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local start, _ = M.range(buf, lnum)
    if direction > 0 then
        for i = lnum + 1, #lines do
            if M.is_delimiter(lines[i]) then
                return i
            end
        end
    else
        -- From inside a cell, go to its own start first, then the one before.
        local from = (start < lnum and M.is_delimiter(lines[start])) and lnum or start
        for i = from - 1, 1, -1 do
            if M.is_delimiter(lines[i]) then
                return i
            end
        end
    end
    return nil
end

--- Move the cursor to the next/previous cell.
function M.jump(direction)
    local target = M.adjacent(0, vim.fn.line("."), direction)
    if target then
        vim.cmd("normal! m'")
        vim.api.nvim_win_set_cursor(0, { target, 0 })
    end
end

--- Select the current cell linewise, for the `ic` (code only) and `ac`
--- (with its delimiter) text objects.
function M.select(around)
    local lnum = vim.fn.line(".")
    local start, finish
    if around then
        start, finish = M.range(0, lnum)
    else
        start, finish = M.body(0, lnum)
    end
    if not start then
        return
    end
    if vim.fn.mode():match("^[vV\22]") then
        vim.cmd("normal! \27")
    end
    vim.api.nvim_win_set_cursor(0, { start, 0 })
    vim.cmd("normal! V")
    vim.api.nvim_win_set_cursor(0, { finish, 0 })
end

--- Send lines {start}..{finish} of the current buffer to the REPL pane.
function M.send_lines(start, finish)
    local text = table.concat(vim.api.nvim_buf_get_lines(0, start - 1, finish, false), "\n")
    vim.fn["slime#send"](text .. "\n")
end

function M.send_cell()
    local start, finish = M.body(0, vim.fn.line("."))
    if start then
        M.send_lines(start, finish)
    end
end

function M.send_cell_and_next()
    M.send_cell()
    M.jump(1)
end

function M.send_selection()
    local start, finish = vim.fn.line("v"), vim.fn.line(".")
    if start > finish then
        start, finish = finish, start
    end
    vim.cmd("normal! \27")
    M.send_lines(start, finish)
end

--- The IPython to start for {buf}'s project: the project's own venv if it
--- has IPython, uv's project environment plus IPython for a uv project,
--- or Nix's IPython otherwise.
function M.ipython_cmd(buf)
    local root = vim.fs.root(buf, { ".venv", "pyproject.toml", ".git" }) or vim.fn.getcwd()
    local venv = vim.fs.joinpath(root, ".venv", "bin", "ipython")
    if vim.fn.executable(venv) == 1 then
        return { venv }, root
    end
    if vim.uv.fs_stat(vim.fs.joinpath(root, "pyproject.toml")) and vim.fn.executable("uv") == 1 then
        return { "uv", "run", "--with", "ipython", "ipython" }, root
    end
    return { "ipython" }, root
end

--- Open IPython in a tmux pane to the right, keep focus here, and point
--- this buffer's slime config at that pane.
function M.open_repl()
    if not vim.env.TMUX then
        vim.notify("The REPL opens in a tmux pane; start nvim inside tmux", vim.log.levels.WARN)
        return
    end
    local cmd, root = M.ipython_cmd(0)
    local result = vim.system({
        "tmux",
        "split-window",
        "-h",
        "-d",
        "-P",
        "-F",
        "#{pane_id}",
        "-c",
        root,
        table.concat(vim.tbl_map(vim.fn.shellescape, cmd), " "),
    }, { text = true }):wait()
    if result.code ~= 0 then
        vim.notify("tmux split-window failed: " .. result.stderr, vim.log.levels.ERROR)
        return
    end
    vim.b.slime_config = { socket_name = M.tmux_socket(), target_pane = vim.trim(result.stdout) }
end

--- The running tmux server's socket path, from $TMUX.
function M.tmux_socket()
    return vim.env.TMUX and vim.split(vim.env.TMUX, ",")[1] or "default"
end

--- Buffer-local maps for a buffer that can hold cells.
function M.attach(buf)
    local function map(mode, lhs, rhs, desc, opts)
        vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { buffer = buf, desc = desc }, opts or {}))
    end
    map("n", "<leader>cc", M.send_cell, "Send cell to REPL")
    map("n", "<leader>cn", M.send_cell_and_next, "Send cell to REPL, go to next")
    map("x", "<leader>cs", M.send_selection, "Send selection to REPL")
    map("n", "<leader>ci", M.open_repl, "Open IPython in a tmux pane")
    -- Diff mode keeps ]c/[c for changes.
    map("n", "]c", function()
        return vim.wo.diff and "]c" or "<cmd>lua require('cdprice.cells').jump(1)<CR>"
    end, "Next cell (next change in diff mode)", { expr = true })
    map("n", "[c", function()
        return vim.wo.diff and "[c" or "<cmd>lua require('cdprice.cells').jump(-1)<CR>"
    end, "Previous cell (previous change in diff mode)", { expr = true })
    map({ "x", "o" }, "ic", function()
        M.select(false)
    end, "Inside cell")
    map({ "x", "o" }, "ac", function()
        M.select(true)
    end, "Around cell")
end

return M
