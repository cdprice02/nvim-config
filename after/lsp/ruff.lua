-- Ruff's native language server: lint diagnostics and code actions. Hover
-- is switched off on attach (lua/cdprice/lazy/lsp.lua) so basedpyright's
-- wins. lineLength matches VS Code's ruff.lineLength.
---@type vim.lsp.Config
return {
    init_options = {
        settings = {
            lineLength = 240,
        },
    },
}
