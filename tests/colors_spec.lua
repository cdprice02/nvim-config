describe("colors", function()
    local function hl(name)
        return vim.api.nvim_get_hl(0, { name = name, link = false })
    end

    it("uses rose-pine", function()
        assert.are.equal("rose-pine", vim.g.colors_name)
    end)

    it("puts #1a1921 behind the editor", function()
        assert.are.equal(0x1a1921, hl("Normal").bg)
    end)

    it("puts #1e1d25 behind floats and menus", function()
        assert.are.equal(0x1e1d25, hl("NormalFloat").bg)
        assert.are.equal(0x1e1d25, hl("Pmenu").bg)
    end)

    it("has no italics", function()
        for _, name in ipairs({ "Comment", "@comment", "@keyword", "@variable.builtin", "@parameter" }) do
            assert.is_falsy(hl(name).italic, name)
        end
    end)
end)
