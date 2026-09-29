local root = assert(os.getenv("NVIM_CONFIG_ROOT"))

describe("lsp config", function()
    local servers = { "rust_analyzer", "basedpyright", "ruff", "lua_ls", "nixd" }

    it("enables every server", function()
        for _, name in ipairs(servers) do
            assert.is_true(vim.lsp.is_enabled(name), name)
        end
    end)

    it("merges overrides onto nvim-lspconfig's definitions", function()
        -- cmd comes from nvim-lspconfig; settings from after/lsp/.
        assert.are.same({ "rust-analyzer" }, vim.lsp.config.rust_analyzer.cmd)
        assert.is_not_nil(vim.lsp.config.rust_analyzer.settings["rust-analyzer"])
    end)

    it("ports the rust-analyzer settings", function()
        local ra = vim.lsp.config.rust_analyzer.settings["rust-analyzer"]
        assert.are.equal("clippy", ra.check.command)
        assert.are.equal("all", ra.cargo.features)
        assert.is_false(ra.cargo.allTargets)
        assert.is_true(ra.cargo.buildScripts.enable)
        assert.are.same({ enforce = true, group = "module" }, ra.imports.granularity)
        assert.is_true(ra.assist.preferSelf)
        assert.is_false(ra.lens.enable)
    end)

    it("ports the Pylance settings to basedpyright", function()
        local analysis = vim.lsp.config.basedpyright.settings.basedpyright.analysis
        assert.are.equal("basic", analysis.typeCheckingMode)
        assert.are.equal("openFilesOnly", analysis.diagnosticMode)
        assert.are.equal("information", analysis.diagnosticSeverityOverrides.reportUnusedImport)
        assert.are.equal("warning", analysis.diagnosticSeverityOverrides.reportImportCycles)
        assert.is_true(analysis.inlayHints.functionReturnTypes)
        assert.is_true(analysis.inlayHints.variableTypes)
    end)

    it("sets ruff's line length to 240", function()
        assert.are.equal(240, vim.lsp.config.ruff.init_options.settings.lineLength)
    end)

    it("tells lua_ls about vim", function()
        assert.are.same({ "vim" }, vim.lsp.config.lua_ls.settings.Lua.diagnostics.globals)
    end)

    it("formats diagnostics as severity + message", function()
        local vt = vim.diagnostic.config().virtual_text
        assert.are.equal("ERROR oops", vt.format({ severity = vim.diagnostic.severity.ERROR, message = "oops" }))
        assert.are.equal("WARNING hmm", vt.format({ severity = vim.diagnostic.severity.WARN, message = "hmm" }))
    end)

    it("maps the inlay hint toggle", function()
        assert.is_false(vim.tbl_isempty(vim.fn.maparg("<Space>ih", "n", false, true)))
    end)
end)

-- Live attach checks run only where the servers are installed (locally via
-- Nix), not in CI.
describe("lsp attach", function()
    --- Open {file} and wait for a client called {name} to attach.
    local function attach(file, name)
        vim.cmd.edit(file)
        local buf = vim.api.nvim_get_current_buf()
        local client
        vim.wait(30000, function()
            client = vim.lsp.get_clients({ bufnr = buf, name = name })[1]
            return client ~= nil and client.initialized
        end, 100)
        return client, buf
    end

    local function live(bin, desc, fn)
        if vim.fn.executable(bin) == 1 then
            it(desc, fn)
        else
            pending(desc .. " (" .. bin .. " not installed)")
        end
    end

    live("lua-language-server", "attaches lua_ls and maps gd", function()
        local client, buf = attach(root .. "/lua/cdprice/set.lua", "lua_ls")
        assert.is_not_nil(client)
        assert.is_false(vim.tbl_isempty(vim.fn.maparg("gd", "n", false, true)))
        assert.are.equal(1, vim.fn.maparg("gd", "n", false, true).buffer)
        assert.is_true(vim.lsp.inlay_hint.is_enabled({ bufnr = buf }))
    end)

    live("ruff", "attaches ruff without hover", function()
        local client = attach(root .. "/tests/fixtures/sample.py", "ruff")
        assert.is_not_nil(client)
        assert.is_falsy(client.server_capabilities.hoverProvider)
    end)

    live("basedpyright-langserver", "attaches basedpyright", function()
        local client = attach(root .. "/tests/fixtures/sample.py", "basedpyright")
        assert.is_not_nil(client)
        assert.is_truthy(client.server_capabilities.hoverProvider)
    end)
end)
