-- lua-language-server, set up for Neovim config code: LuaJIT, and `vim`
-- plus the Neovim runtime known, so vim.* resolves and isn't flagged.
---@type vim.lsp.Config
return {
    settings = {
        Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
                checkThirdParty = false,
                library = { vim.env.VIMRUNTIME },
            },
            telemetry = { enable = false },
        },
    },
}
