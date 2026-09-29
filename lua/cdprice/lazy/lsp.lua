-- Language servers through Neovim's own vim.lsp.config/vim.lsp.enable
-- (0.11+). nvim-lspconfig is only a library of server definitions (its
-- lsp/<name>.lua files); this config's overrides live in after/lsp/, which
-- is merged after them. Every server binary comes from Nix (neovim.nix and
-- the lang-* features), never Mason.
--
-- Keymaps are Neovim's defaults: K hover, grn rename, gra code action,
-- grr references, gri implementation, gO document symbols, [d/]d
-- diagnostics, <C-w>d diagnostic float, <C-s> signature help (insert).
-- Added here: gd and the inlay-hint toggle.

local servers = {
    "rust_analyzer",
    "basedpyright",
    "ruff",
    "lua_ls",
    "nixd",
}

-- errorLens.messageTemplate "$severity $message", with errorLens's own
-- severity labels.
local severity_label = {
    [vim.diagnostic.severity.ERROR] = "ERROR",
    [vim.diagnostic.severity.WARN] = "WARNING",
    [vim.diagnostic.severity.INFO] = "INFO",
    [vim.diagnostic.severity.HINT] = "HINT",
}

local function setup_diagnostics()
    vim.diagnostic.config({
        severity_sort = true,
        virtual_text = {
            prefix = "",
            format = function(d)
                return ("%s %s"):format(severity_label[d.severity], d.message)
            end,
        },
        float = { border = "rounded", source = true },
    })
end

--- editor.gotoLocation.multipleDefinitions: "goto" -- jump straight to the
--- first result instead of opening a list to pick from.
local function goto_first(method)
    return function()
        method({
            on_list = function(opts)
                vim.fn.setqflist({}, " ", opts)
                vim.cmd("silent cfirst")
            end,
        })
    end
end

local function on_attach(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    local buf = args.buf

    -- Ruff lints and formats; hover belongs to basedpyright.
    if client.name == "ruff" then
        client.server_capabilities.hoverProvider = false
    end

    if client:supports_method("textDocument/definition") then
        vim.keymap.set("n", "gd", goto_first(vim.lsp.buf.definition), { buffer = buf, desc = "Go to definition" })
    end

    -- editor.inlayHints defaults to on in VS Code.
    if client:supports_method("textDocument/inlayHint") then
        vim.lsp.inlay_hint.enable(true, { bufnr = buf })
    end
end

return {
    {
        "neovim/nvim-lspconfig",
        version = "*",
        lazy = false,
        config = function()
            vim.o.winborder = "rounded"
            setup_diagnostics()

            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("cdprice.lsp", {}),
                callback = on_attach,
            })

            vim.keymap.set("n", "<leader>ih", function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end, { desc = "Toggle inlay hints" })

            vim.lsp.enable(servers)
        end,
    },
    {
        -- LSP progress (indexing, cargo check) in the corner.
        "j-hui/fidget.nvim",
        version = "*",
        event = "LspAttach",
        opts = {},
    },
}
