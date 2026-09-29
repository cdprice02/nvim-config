--- The {rhs} of a mapping, or nil when {lhs} isn't mapped in {mode}.
--- Key notation is normalized through vim.keycode, so "<cmd>" and "<Cmd>"
--- (maparg returns whichever spelling the mapping was defined with) compare
--- equal.
local function rhs(mode, lhs)
    local m = vim.fn.maparg(lhs, mode, false, true)
    if vim.tbl_isempty(m) then
        return nil
    end
    return m.callback or vim.keycode(m.rhs)
end

describe("remaps", function()
    local cases = {
        { "v", "J", ":m '>+1<CR>gv=gv" },
        { "v", "K", ":m '<-2<CR>gv=gv" },
        { "n", "J", "mzJ`z" },
        { "n", "<C-D>", "<C-D>zz" },
        { "n", "<C-U>", "<C-U>zz" },
        { "n", "n", "nzzzv" },
        { "n", "N", "Nzzzv" },
        { "x", "<Space>p", [["_dP]] },
        { "n", "<Space>y", [["+y]] },
        { "v", "<Space>y", [["+y]] },
        { "n", "<Space>Y", [["+Y]] },
        { "n", "<Space>d", [["_d]] },
        { "v", "<Space>d", [["_d]] },
        { "n", "Q", "<nop>" },
        { "n", "<C-K>", "<Cmd>cnext<CR>zz" },
        { "n", "<C-J>", "<Cmd>cprev<CR>zz" },
        { "n", "<Space>k", "<Cmd>lnext<CR>zz" },
        { "n", "<Space>j", "<Cmd>lprev<CR>zz" },
        { "i", "<C-C>", "<Esc>" },
        { "n", "<Space><Space>", "<Cmd>source<CR>" },
        { "n", "<Space>x", "<Cmd>!chmod +x %<CR>" },
    }

    for _, case in ipairs(cases) do
        local mode, lhs, want = case[1], case[2], case[3]
        it(("maps %s %s"):format(mode, lhs), function()
            assert.are.equal(vim.keycode(want), rhs(mode, lhs))
        end)
    end

    it("maps <leader>s to a word-under-cursor substitute", function()
        assert.matches("^:%%s/", vim.fn.maparg("<Space>s", "n"))
    end)

    it("maps <leader>pv to the file explorer", function()
        assert.is_not_nil(rhs("n", "<Space>pv"))
    end)

    -- 1=c: LSP actions come from Neovim's own defaults, not from this config.
    it("leaves the built-in LSP defaults in place", function()
        for _, lhs in ipairs({ "grn", "gra", "grr", "gri" }) do
            assert.is_not_nil(rhs("n", lhs), lhs)
        end
    end)
end)
