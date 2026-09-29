local wsl = require("cdprice.wsl")

describe("wsl clipboard", function()
    it("is set up only under WSL", function()
        if vim.fn.has("wsl") == 1 then
            assert.are.equal("wsl", vim.g.clipboard.name)
        else
            assert.is_nil(vim.g.clipboard)
        end
    end)

    it("copies with OSC 52 and pastes with powershell.exe", function()
        local p = wsl.provider()
        assert.are.equal("function", type(p.copy["+"]))
        assert.are.equal("function", type(p.copy["*"]))
        assert.matches("powershell%.exe$", p.paste["+"][1])
        assert.are.same(p.paste["+"], p.paste["*"])
    end)
end)
