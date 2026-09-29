local function mapped(lhs)
    return not vim.tbl_isempty(vim.fn.maparg(lhs, "n", false, true))
end

describe("trouble", function()
    it("maps the problem and TODO lists", function()
        for _, lhs in ipairs({ "<Space>tt", "<Space>td", "]t", "[t" }) do
            assert.is_true(mapped(lhs), lhs)
        end
    end)

    it("opens the diagnostics list", function()
        vim.cmd.enew()
        vim.cmd("Trouble diagnostics open")
        assert.is_true(require("trouble").is_open("diagnostics"))
        vim.cmd("Trouble diagnostics close")
    end)
end)

describe("todo-comments", function()
    it("highlights TODOs", function()
        local path = vim.fn.tempname() .. ".lua"
        vim.fn.writefile({ "-- TODO: something", "local x = 1" }, path)
        vim.cmd.edit(path)
        local buf = vim.api.nvim_get_current_buf()
        local ns = vim.api.nvim_get_namespaces()["todo-comments"]
        local ok = vim.wait(3000, function()
            return ns ~= nil and #vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {}) > 0
        end, 50)
        assert.is_true(ok)
    end)
end)

describe("cloak", function()
    it("masks .env values", function()
        local dir = vim.fn.tempname()
        vim.fn.mkdir(dir, "p")
        vim.fn.writefile({ "API_KEY=secret" }, dir .. "/.env")
        vim.cmd.edit(dir .. "/.env")
        local buf = vim.api.nvim_get_current_buf()
        local ns = vim.api.nvim_create_namespace("cloak")
        local ok = vim.wait(3000, function()
            return #vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {}) > 0
        end, 50)
        assert.is_true(ok, "the value should be covered by a cloak extmark")
    end)
end)

describe("zen-mode", function()
    it("maps <leader>zz", function()
        assert.is_true(mapped("<Space>zz"))
    end)
end)

describe("obsidian", function()
    --- Whether obsidian.nvim is active in a fresh nvim with {vault} as
    --- OBSIDIAN_VAULT.
    local function active_with(vault)
        local env = vim.fn.environ()
        env.OBSIDIAN_VAULT = vault
        local result = vim.system({
            vim.v.progpath,
            "--headless",
            "-c",
            [[lua io.stdout:write(tostring(require("lazy.core.config").plugins["obsidian.nvim"] ~= nil))]],
            "+qa!",
        }, { env = env, clear_env = true, text = true }):wait(60000)
        assert.are.equal(0, result.code, result.stderr)
        return result.stdout == "true"
    end

    it("stays off when OBSIDIAN_VAULT is empty", function()
        assert.is_false(active_with(""))
    end)

    it("stays off when the vault doesn't exist", function()
        assert.is_false(active_with("/nonexistent/vault"))
    end)

    it("turns on for a real vault", function()
        local vault = vim.fn.tempname()
        vim.fn.mkdir(vault, "p")
        assert.is_true(active_with(vault))
    end)
end)
