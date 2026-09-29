local function conform()
    require("lazy").load({ plugins = { "conform.nvim" } })
    return require("conform")
end

--- A scratch buffer of filetype {ft} holding {lines}, saved to a temp file
--- so formatters that look at the filename (ruff, stylua) see one.
local function buffer(ft, ext, lines)
    local path = vim.fn.tempname() .. "." .. ext
    vim.fn.writefile(lines, path)
    vim.cmd.edit(path)
    vim.bo.filetype = ft
    return vim.api.nvim_get_current_buf(), path
end

describe("format config", function()
    it("organizes imports, then formats, for Python", function()
        assert.are.same({ "ruff_organize_imports", "ruff_format" }, conform().formatters_by_ft.python)
    end)

    it("covers the other languages", function()
        local by_ft = conform().formatters_by_ft
        assert.are.same({ "stylua" }, by_ft.lua)
        assert.are.same({ "nixfmt" }, by_ft.nix)
        assert.are.same({ "taplo" }, by_ft.toml)
        assert.are.same({ "shfmt" }, by_ft.sh)
        for _, ft in ipairs({ "json", "jsonc", "yaml", "markdown" }) do
            assert.are.same({ "prettierd" }, by_ft[ft], ft)
        end
        -- Rust formats through rust-analyzer.
        assert.is_nil(by_ft.rust)
    end)

    it("formats on save, with a global and a per-buffer switch", function()
        conform()
        local buf = vim.api.nvim_get_current_buf()
        assert.are.equal(2, vim.fn.exists(":FormatToggle"))

        vim.cmd("FormatToggle")
        assert.is_true(vim.g.disable_autoformat)
        vim.cmd("FormatToggle")
        assert.is_false(vim.g.disable_autoformat)

        vim.cmd("FormatToggle!")
        assert.is_true(vim.b[buf].disable_autoformat)
        vim.cmd("FormatToggle!")
        assert.is_false(vim.b[buf].disable_autoformat)
    end)

    it("maps <leader>f in normal and visual mode", function()
        for _, mode in ipairs({ "n", "v" }) do
            assert.is_false(vim.tbl_isempty(vim.fn.maparg("<Space>f", mode, false, true)), mode)
        end
    end)

    it("points prettierd at VS Code's prettier defaults", function()
        local path = conform().formatters.prettierd.env.PRETTIERD_DEFAULT_CONFIG
        local prettierrc = vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
        assert.are.same({ quoteProps = "consistent", trailingComma = "all" }, prettierrc)
    end)
end)

-- Real formatter runs, only where the binaries are installed (Nix), not CI.
describe("format on save", function()
    local function live(bin, desc, fn)
        if vim.fn.executable(bin) == 1 then
            it(desc, fn)
        else
            pending(desc .. " (" .. bin .. " not installed)")
        end
    end

    local function save_and_read(buf)
        vim.api.nvim_buf_call(buf, function()
            vim.cmd("write")
        end)
        return vim.api.nvim_buf_get_lines(buf, 0, -1, true)
    end

    live("ruff", "sorts imports and formats Python", function()
        conform()
        local buf = buffer("python", "py", { "import sys", "import os", "x = {'a':1}" })
        assert.are.same({ "import os", "import sys", "", 'x = {"a": 1}' }, save_and_read(buf))
    end)

    live("ruff", "keeps lines up to 240 columns", function()
        conform()
        local long = 'x = ["' .. string.rep("a", 100) .. '", "' .. string.rep("b", 100) .. '"]'
        local buf = buffer("python", "py", { long })
        assert.are.same({ long }, save_and_read(buf))
    end)

    live("stylua", "formats Lua", function()
        conform()
        local buf = buffer("lua", "lua", { "local x={a=1,b=2}", "return x" })
        assert.are.same({ "local x = { a = 1, b = 2 }", "return x" }, save_and_read(buf))
    end)

    live("prettierd", "formats JSON", function()
        conform()
        -- Prettier keeps an object on one line unless its first key starts
        -- on a new line, as here.
        local buf = buffer("json", "json", { "{", '"a":1,"b":[1,2]}' })
        assert.are.same({ "{", '  "a": 1,', '  "b": [1, 2]', "}" }, save_and_read(buf))
    end)

    live("ruff", "skips formatting while switched off", function()
        conform()
        local buf = buffer("python", "py", { "import sys", "import os" })
        vim.b[buf].disable_autoformat = true
        assert.are.same({ "import sys", "import os" }, save_and_read(buf))
    end)
end)
