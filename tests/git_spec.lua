--- A throwaway git repo holding a committed a.txt; returns its path.
local function repo()
    local dir = vim.fn.tempname()
    vim.fn.mkdir(dir, "p")
    local function git(...)
        local r = vim.system({ "git", "-C", dir, ... }, { text = true }):wait()
        assert(r.code == 0, r.stderr)
    end
    git("init", "-q")
    git("config", "user.email", "test@example.com")
    git("config", "user.name", "test")
    vim.fn.writefile({ "one", "two", "three" }, dir .. "/a.txt")
    git("add", "a.txt")
    git("commit", "-q", "-m", "init")
    return dir
end

local function mapped(mode, lhs, buffer_local)
    local m = vim.fn.maparg(lhs, mode, false, true)
    if vim.tbl_isempty(m) then
        return false
    end
    return not buffer_local or m.buffer == 1
end

describe("fugitive", function()
    it("opens status on <leader>gs", function()
        assert.is_true(mapped("n", "<Space>gs"))
    end)

    it("maps push/pull in the status window", function()
        local dir = repo()
        vim.cmd.edit(dir .. "/a.txt")
        vim.cmd("Git")
        assert.are.equal("fugitive", vim.bo.filetype)
        for _, lhs in ipairs({ "<Space>p", "<Space>P", "<Space>t" }) do
            assert.is_true(mapped("n", lhs, true), lhs)
        end
        vim.cmd.close()
    end)

    it("keeps gu/gh as usual outside diff mode", function()
        vim.cmd.enew()
        vim.wo.diff = false
        assert.are.equal("gu", vim.fn.maparg("gu", "n", false, true).callback())
        assert.are.equal("gh", vim.fn.maparg("gh", "n", false, true).callback())
        vim.wo.diff = true
        assert.matches("diffget //2", vim.fn.maparg("gu", "n", false, true).callback())
        assert.matches("diffget //3", vim.fn.maparg("gh", "n", false, true).callback())
        vim.wo.diff = false
    end)
end)

describe("gitsigns", function()
    it("attaches in a repo with hunk keymaps", function()
        local dir = repo()
        vim.cmd.edit(dir .. "/a.txt")
        local buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_set_lines(buf, 1, 2, true, { "TWO" })

        local ok = vim.wait(5000, function()
            local status = vim.b[buf].gitsigns_status_dict
            return status ~= nil and (status.changed or 0) > 0
        end, 50)
        assert.is_true(ok, "gitsigns should report the changed line")

        for _, lhs in ipairs({ "]h", "[h", "<Space>hs", "<Space>hr", "<Space>hp", "<Space>hb" }) do
            assert.is_true(mapped("n", lhs, true), lhs)
        end
        assert.is_true(mapped("v", "<Space>hs", true))
    end)
end)

describe("lazygit", function()
    it("maps <leader>lg", function()
        assert.is_true(mapped("n", "<Space>lg"))
    end)
end)
