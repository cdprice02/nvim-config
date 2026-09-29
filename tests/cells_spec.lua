local root = assert(os.getenv("NVIM_CONFIG_ROOT"))
local cells = require("cdprice.cells")

--- A Python buffer holding {lines}.
local function python(lines)
    local path = vim.fn.tempname() .. ".py"
    vim.fn.writefile(lines, path)
    vim.cmd.edit(path)
    return vim.api.nvim_get_current_buf()
end

local SAMPLE = {
    "import os", --  1  (before the first delimiter)
    "", --           2
    "# %%", --       3
    "a = 1", --      4
    "b = 2", --      5
    "", --           6
    "#%% [markdown]", -- 7
    "# notes", --    8
    "# %%", --       9
    "c = 3", --     10
}

describe("cell detection", function()
    it("finds each cell's lines", function()
        local buf = python(SAMPLE)
        assert.are.same({ 1, 2 }, { cells.range(buf, 1) })
        assert.are.same({ 3, 6 }, { cells.range(buf, 3) })
        assert.are.same({ 3, 6 }, { cells.range(buf, 5) })
        assert.are.same({ 7, 8 }, { cells.range(buf, 8) })
        assert.are.same({ 9, 10 }, { cells.range(buf, 10) })
    end)

    it("takes a cell's code without its delimiter or trailing blanks", function()
        local buf = python(SAMPLE)
        assert.are.same({ 1, 1 }, { cells.body(buf, 2) })
        assert.are.same({ 4, 5 }, { cells.body(buf, 4) })
        assert.are.same({ 10, 10 }, { cells.body(buf, 9) })
    end)

    it("treats an empty cell as nothing to send", function()
        local buf = python({ "# %%", "", "# %%", "x = 1" })
        assert.is_nil(cells.body(buf, 1))
    end)

    it("moves to the next and previous cell", function()
        local buf = python(SAMPLE)
        assert.are.equal(3, cells.adjacent(buf, 1, 1))
        assert.are.equal(7, cells.adjacent(buf, 4, 1))
        assert.is_nil(cells.adjacent(buf, 10, 1))
        -- From inside a cell, back to its own start first.
        assert.are.equal(9, cells.adjacent(buf, 10, -1))
        assert.are.equal(7, cells.adjacent(buf, 9, -1))
        assert.is_nil(cells.adjacent(buf, 3, -1))
    end)
end)

describe("cell keymaps", function()
    it("jump with ]c/[c, but keep diff navigation in diff mode", function()
        python(SAMPLE)
        vim.api.nvim_win_set_cursor(0, { 4, 0 })
        vim.cmd("normal ]c")
        assert.are.equal(7, vim.fn.line("."))
        vim.cmd("normal [c")
        assert.are.equal(3, vim.fn.line("."))

        vim.wo.diff = true
        assert.are.equal("]c", vim.fn.maparg("]c", "n", false, true).callback())
        vim.wo.diff = false
    end)

    it("delete a cell's code with dic, and the whole cell with dac", function()
        local buf = python(SAMPLE)
        vim.api.nvim_win_set_cursor(0, { 4, 0 })
        vim.cmd("normal dic")
        assert.are.same({ "# %%", "", "#%% [markdown]" }, vim.api.nvim_buf_get_lines(buf, 2, 5, false))

        buf = python(SAMPLE)
        vim.api.nvim_win_set_cursor(0, { 10, 0 })
        vim.cmd("normal dac")
        assert.are.same("# notes", vim.api.nvim_buf_get_lines(buf, -2, -1, false)[1])
    end)

    it("map the sends only in Python buffers", function()
        python(SAMPLE)
        for _, lhs in ipairs({ "<Space>cc", "<Space>cn", "<Space>ci" }) do
            assert.is_false(vim.tbl_isempty(vim.fn.maparg(lhs, "n", false, true)), lhs)
        end
        assert.is_false(vim.tbl_isempty(vim.fn.maparg("<Space>cs", "x", false, true)))

        vim.cmd.edit(vim.fn.tempname() .. ".lua")
        assert.is_true(vim.tbl_isempty(vim.fn.maparg("<Space>cc", "n", false, true)))
        assert.are.equal("", vim.fn.maparg("]c", "n"))
    end)
end)

describe("REPL", function()
    it("picks the project's own IPython", function()
        local dir = vim.fn.tempname()
        vim.fn.mkdir(dir .. "/.venv/bin", "p")
        vim.fn.writefile({ "#!/bin/sh" }, dir .. "/.venv/bin/ipython")
        vim.fn.setfperm(dir .. "/.venv/bin/ipython", "rwxr-xr-x")
        vim.fn.writefile({ "x = 1" }, dir .. "/main.py")
        vim.cmd.edit(dir .. "/main.py")
        local cmd, cwd = cells.ipython_cmd(0)
        assert.are.same({ dir .. "/.venv/bin/ipython" }, cmd)
        assert.are.equal(dir, cwd)
    end)

    local live = (vim.fn.executable("tmux") == 1 and vim.fn.executable("ipython") == 1) and it or pending
    live("sends cells to IPython in a tmux pane", function()
        local socket = "nvim-config-test-" .. vim.fn.getpid()
        local function tmux(...)
            return vim.system({ "tmux", "-L", socket, ... }, { text = true }):wait()
        end
        tmux("new-session", "-d", "-s", "t", "-x", "200", "-y", "50", "ipython --no-banner")
        local pane = vim.trim(tmux("list-panes", "-t", "t", "-F", "#{pane_id}").stdout)
        local path = vim.trim(tmux("display", "-p", "#{socket_path}").stdout)
        local function screen()
            return tmux("capture-pane", "-p", "-t", pane).stdout
        end
        vim.wait(15000, function()
            return screen():find("In %[1%]") ~= nil
        end, 100)

        python({ "# %%", "for i in range(2):", "    print('row', i)", "", "# %%", "print('done')" })
        vim.b.slime_config = { socket_name = path, target_pane = pane }
        vim.api.nvim_win_set_cursor(0, { 2, 0 })
        cells.send_cell_and_next()
        assert.are.equal(5, vim.fn.line("."))
        cells.send_cell()

        local ok = vim.wait(10000, function()
            return screen():find("row 1") ~= nil and screen():find("\ndone") ~= nil
        end, 100)
        tmux("kill-server")
        assert.is_true(ok, screen())
    end)
end)

describe("notebooks", function()
    local live = vim.fn.executable("jupytext") == 1 and it or pending
    live("open as # %% cells and save back, keeping outputs", function()
        local path = vim.fn.tempname() .. ".ipynb"
        vim.fn.writefile(vim.fn.readfile(root .. "/tests/fixtures/sample.ipynb"), path)
        vim.cmd.edit(path)
        local buf = vim.api.nvim_get_current_buf()
        assert.are.equal("python", vim.bo.filetype)
        local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
        assert.matches("# %%%%\nx = 1 %+ 2\nprint%(x%)", text)

        vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "y = x*10" })
        vim.cmd("write")
        assert.is_false(vim.bo.modified)

        local nb = vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
        local code = nb.cells[2]
        -- Formatted on save by ruff where it's installed, and the saved
        -- output kept.
        local y = vim.fn.executable("ruff") == 1 and "y = x * 10" or "y = x*10"
        assert.are.same({ "x = 1 + 2\n", "print(x)\n", y }, code.source)
        assert.are.equal("3\n", code.outputs[1].text[1])
    end)
end)
