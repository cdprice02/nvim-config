local fixtures = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h") .. "/fixtures"

--- Open {file} from tests/fixtures and report whether treesitter is
--- highlighting it.
local function highlighted(file)
    vim.cmd.edit(fixtures .. "/" .. file)
    local buf = vim.api.nvim_get_current_buf()
    return vim.treesitter.highlighter.active[buf] ~= nil, buf
end

describe("treesitter", function()
    it("loads the branch matching this Neovim", function()
        local want = vim.fn.has("nvim-0.12") == 1 and "nvim-treesitter" or "nvim-treesitter-master"
        local other = want == "nvim-treesitter" and "nvim-treesitter-master" or "nvim-treesitter"
        local config = require("lazy.core.config")
        assert.is_not_nil(config.plugins[want], want .. " should be active")
        assert.is_not_nil(config.plugins[want]._.loaded, want .. " should be loaded")
        assert.is_nil(config.plugins[other], other .. " should not be active")
        assert.is_not_nil(config.spec.disabled[other], other .. " should be declared but off")
    end)

    it("keeps both branches pinned in lazy-lock.json", function()
        local lock = vim.json.decode(table.concat(vim.fn.readfile(require("lazy.core.config").options.lockfile), "\n"))
        assert.are.equal("main", lock["nvim-treesitter"].branch)
        assert.are.equal("master", lock["nvim-treesitter-master"].branch)
    end)

    for _, file in ipairs({ "sample.rs", "sample.py", "sample.nix", "sample.toml" }) do
        it("highlights " .. file, function()
            local active = highlighted(file)
            assert.is_true(active)
        end)
    end

    it("indents with treesitter", function()
        local _, buf = highlighted("sample.py")
        -- main: v:lua.require'nvim-treesitter'.indentexpr(); master: nvim_treesitter#indent()
        assert.matches("nvim[-_]treesitter", vim.bo[buf].indentexpr)
    end)
end)
