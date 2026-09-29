describe("completion", function()
    local config = function()
        return require("blink.cmp.config")
    end

    it("never accepts on <CR>", function()
        vim.cmd.enew()
        vim.cmd.startinsert()
        local map = vim.fn.maparg("<CR>", "i", false, true)
        vim.cmd.stopinsert()
        -- Unmapped, or at least not blink's.
        assert.is_true(vim.tbl_isempty(map) or not tostring(map.desc or ""):lower():find("blink"))
        assert.is_nil(config().keymap["<CR>"])
    end)

    it("accepts on <C-y> and navigates with <C-n>/<C-p>", function()
        assert.are.equal("default", config().keymap.preset)
    end)

    it("uses lsp, path, snippets and buffer", function()
        assert.are.same({ "lsp", "path", "snippets", "buffer" }, config().sources.default)
    end)

    it("preselects without inserting, and adds no brackets", function()
        local completion = config().completion
        -- blink wraps mode-dependent options in a function of the mode.
        local auto_insert = completion.list.selection.auto_insert
        if type(auto_insert) == "function" then
            auto_insert = auto_insert({})
        end
        assert.is_false(auto_insert)
        assert.is_false(completion.accept.auto_brackets.enabled)
    end)

    it("uses the native fuzzy matcher", function()
        -- Downloaded with the release tag; loading it fails if it's missing.
        assert.is_true(pcall(require, "blink.cmp.fuzzy.rust"))
    end)

    it("advertises its capabilities to every server", function()
        local caps = vim.lsp.config["*"].capabilities
        assert.is_not_nil(caps)
        local item = caps.textDocument.completion.completionItem
        assert.is_true(item.snippetSupport)
        -- Resolved per server too, e.g. rust_analyzer.
        local ra = vim.lsp.config.rust_analyzer.capabilities
        assert.is_true(ra.textDocument.completion.completionItem.snippetSupport)
    end)
end)
