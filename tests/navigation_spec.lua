local function load(name)
    require("lazy").load({ plugins = { name } })
end

--- True when {lhs} is mapped in normal mode (lazy.nvim's key stubs count).
local function mapped(lhs)
    return not vim.tbl_isempty(vim.fn.maparg(lhs, "n", false, true))
end

describe("telescope", function()
    it("maps Prime's pickers", function()
        for _, lhs in ipairs({ "<Space>pf", "<C-P>", "<Space>ps", "<Space>pws", "<Space>pWs", "<Space>vh" }) do
            assert.is_true(mapped(lhs), lhs)
        end
    end)

    it("loads with the native fzf sorter", function()
        load("telescope.nvim")
        assert.is_not_nil(require("telescope").extensions.fzf)
        -- The compiled library itself, not just the Lua wrapper around it.
        assert.is_true(pcall(require, "fzf_lib"))
    end)
end)

describe("harpoon", function()
    it("maps add, menu and slots 1-4", function()
        for _, lhs in ipairs({ "<Space>a", "<Space>A", "<C-E>", "<Space>1", "<Space>2", "<Space>3", "<Space>4" }) do
            assert.is_true(mapped(lhs), lhs)
        end
    end)

    it("pins the current file", function()
        load("harpoon")
        local harpoon = require("harpoon")
        local list = harpoon:list()
        list:clear()
        vim.cmd.edit(vim.fn.tempname() .. ".txt")
        list:add()
        assert.are.equal(1, list:length())
        list:clear()
    end)
end)

describe("oil", function()
    it("maps <leader>pv", function()
        assert.is_true(mapped("<Space>pv"))
    end)

    it("takes over directory buffers", function()
        local dir = vim.fn.tempname()
        vim.fn.mkdir(dir, "p")
        vim.cmd.edit(dir)
        vim.wait(2000, function()
            return vim.bo.filetype == "oil"
        end)
        assert.are.equal("oil", vim.bo.filetype)
    end)
end)

describe("undotree", function()
    it("toggles on <leader>u", function()
        assert.is_true(mapped("<Space>u"))
        load("undotree")
        assert.are.equal(2, vim.fn.exists(":UndotreeToggle"))
    end)
end)
