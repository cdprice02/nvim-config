describe("autocmds", function()
    local buf

    before_each(function()
        buf = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_set_current_buf(buf)
    end)

    after_each(function()
        vim.api.nvim_buf_delete(buf, { force = true })
    end)

    local function write_pre()
        vim.api.nvim_exec_autocmds("BufWritePre", { buffer = buf })
        return vim.api.nvim_buf_get_lines(buf, 0, -1, true)
    end

    it("trims trailing whitespace on save", function()
        vim.api.nvim_buf_set_lines(buf, 0, -1, true, { "local x = 1  ", "\t", "return x\t" })
        assert.are.same({ "local x = 1", "", "return x" }, write_pre())
    end)

    it("trims trailing blank lines on save", function()
        vim.api.nvim_buf_set_lines(buf, 0, -1, true, { "a", "", "b", "", "  ", "" })
        assert.are.same({ "a", "", "b" }, write_pre())
    end)

    it("keeps the cursor where it was", function()
        vim.api.nvim_buf_set_lines(buf, 0, -1, true, { "one   ", "two   ", "three" })
        vim.api.nvim_win_set_cursor(0, { 2, 1 })
        write_pre()
        assert.are.same({ 2, 1 }, vim.api.nvim_win_get_cursor(0))
    end)

    it("doesn't touch the search register", function()
        vim.fn.setreg("/", "needle")
        vim.api.nvim_buf_set_lines(buf, 0, -1, true, { "x  " })
        write_pre()
        assert.are.equal("needle", vim.fn.getreg("/"))
    end)

    it("highlights on yank", function()
        local cmds = vim.api.nvim_get_autocmds({ group = "HighlightYank", event = "TextYankPost" })
        assert.are.equal(1, #cmds)
    end)
end)
